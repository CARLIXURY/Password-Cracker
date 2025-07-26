#!/usr/bin/env perl

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use Digest::SHA qw(sha1_hex sha256_hex);

my $hash_file = 'hashes.txt';
my $wordlist  = 'dict.txt';

open(my $hf, '<', $hash_file) or die "Cannot open $hash_file: $!";
open(my $wf, '<', $wordlist)  or die "Cannot open $wordlist: $!";

my @hashes = <$hf>;
chomp @hashes;

print "[*] Starting password cracking...\n";

while (my $word = <$wf>) {
    chomp $word;

    my $md5    = md5_hex($word);
    my $sha1   = sha1_hex($word);
    my $sha256 = sha256_hex($word);

    foreach my $hash (@hashes) {
        if ($hash eq $md5 || $hash eq $sha1 || $hash eq $sha256) {
            print "[+] Match found: $word => $hash\n";
        }
    }
}

print "[*] Cracking completed!\n";
