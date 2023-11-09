#!/usr/bin/perl -I /usr/gms/t/lib/

our $AUTHORITY = 'cpan:gluesys';
our $DESCRIPTOIN = "Network Address API가 Slave interface에 주소 할당을 방지하는지 확인하는 테스트";

use strict;
use warnings;
use utf8;

use Env;
use Test::Most;
use Test::AnyStor::Network;

$ENV{GMS_TEST_ADDR} = shift(@ARGV) if @ARGV;
$ENV{GMS_TEST_IFACE} = shift(@ARGV) if @ARGV;

my $GMS_TEST_ADDR = $ENV{GMS_TEST_ADDR};
my $GMS_TEST_IFACE = $ENV{GMS_TEST_IFACE};

my $verbose = 0;

my $TEST_IP_POOL_START = '100.0.0.1';
my $TEST_IP_POOL_END   = '100.0.0.10';

my @TEST_IP_POOL;
my $POOL_SIZE;

if (!defined($GMS_TEST_ADDR) || !defined($GMS_TEST_IFACE))
{
    ok(0, 'argument missing');
    return 1;
}

sub addr_to_dec
{
    my $addr = shift;

    my $decimal_addr = 0;
    my @addr_split = split(/\./, $addr);

    for (my $class = 0; $class < 4; $class++)
    {
        $decimal_addr += ($addr_split[3-$class] << (8 * $class));
    }

    return $decimal_addr;
}

sub dec_to_addr
{
    my $decimal_addr = shift;

    my @addr_split = (
        ($decimal_addr & 255*256*256*256) >> 24,
        ($decimal_addr & 255*256*256) >> 16,
        ($decimal_addr & 255*256) >> 8,
        ($decimal_addr & 255) >> 0
    );

    return join('.', @addr_split);
}

subtest 'make_test_ip_pool' => sub
{
    my $dec_pool_start = addr_to_dec($TEST_IP_POOL_START);
    my $dec_pool_end   = addr_to_dec($TEST_IP_POOL_END);

    for (my $dec_addr = $dec_pool_start
        ; $dec_addr <= $dec_pool_end
        ; $dec_addr++)
    {
        push(@TEST_IP_POOL, dec_to_addr($dec_addr));
    }

    $POOL_SIZE = scalar(@TEST_IP_POOL);

    ok(1, "Test ip pool has been created (size: $POOL_SIZE, range: $TEST_IP_POOL_START ~ $TEST_IP_POOL_END)");
};

subtest "initialize test device($GMS_TEST_IFACE)" => sub
{
    my $t = Test::AnyStor::Network->new(addr => $GMS_TEST_ADDR);

    $t->network_device_update(
        devname => $GMS_TEST_IFACE,
        mtu     => 1500,
        active  => 'off'
    );
};

my $test_bond;

subtest 'initialize test bond' => sub
{
    my $t = Test::AnyStor::Network->new(addr => $GMS_TEST_ADDR);

    $test_bond = $t->network_bonding_create(
        slave  => [ $GMS_TEST_IFACE ],
        mode   => 0,
        mtu    => 1500,
        active => 'off'
    );
};

subtest 'Address API: assign address to slave interface test' => sub
{
    my $t = Test::AnyStor::Network->new(addr => $GMS_TEST_ADDR);

    my $created_addr = $TEST_IP_POOL[rand($POOL_SIZE)];

    my $result = $t->network_address_create(
        devname      => $GMS_TEST_IFACE,
        ipaddr       => $created_addr,
        netmask      => '255.255.255.0',
        active       => 'off',
        return_false => 1
    );

    ok($result, "address assign to slave interface check");
};

subtest 'reset test bond' => sub
{
    my $t = Test::AnyStor::Network->new(addr => $GMS_TEST_ADDR);

    $t->network_bonding_delete(bondname => $test_bond);
};

subtest "reset test device($GMS_TEST_IFACE)" => sub
{
    my $t = Test::AnyStor::Network->new(addr => $GMS_TEST_ADDR);

    $t->network_device_update(
        devname => $GMS_TEST_IFACE,
        mtu     => 1500,
        active  => 'off'
    );
};

done_testing();
