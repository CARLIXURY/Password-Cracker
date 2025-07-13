
#!/usr/bin/env perl

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use Digest::SHA qw(sha1_hex sha256_hex);

my $hash_file = $ARGV[0] || die ("usage: $0 hashlist\n");

print "✅ Enhanced Hash Cracker - Multi-Algorithm Support!\n";
print "Hash file provided: $hash_file\n";

# Read hashes from file
open(my $fh, '<', $hash_file) or die "Cannot open file '$hash_file': $!";
my @hashes = ();
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^\s*$/; # skip empty lines
    push @hashes, lc($line); # convert to lowercase for comparison
}
close($fh);

print "[*] Loaded " . scalar(@hashes) . " hash(es) from $hash_file\n";

# Enhanced dictionary of common passwords
my @dictionary = qw(
    password 123456 12345678 qwerty abc123 monkey letmein dragon
    111111 baseball iloveyou trustno1 1234567890 sunshine master
    123123 welcome shadow ashley football jesus michael ninja mustang
    hello admin pass test guest info admin admin123 root toor
    administrator guest user demo sample welcome1 password1 
    123456789 picture1 password123 123qwe qwerty123 hello123
    a aa aaa aaaa aaaaa aaaaaa aaaaaaa aaaaaaaa
    b bb bbb bbbb bbbbb bbbbbb bbbbbbb bbbbbbbb
    c cc ccc cccc ccccc cccccc ccccccc cccccccc
    1 12 123 1234 12345 123456 1234567 12345678
    love god secret jesus password123 qwerty123 abc123456
    password1 123456789 welcome123 administrator root123
);

my $cracked_count = 0;
my $failed_count = 0;
my @cracked_results = ();
my @failed_hashes = ();
my $start_time = time();

print "[*] Starting smart hash cracking...\n";

foreach my $hash (@hashes) {
    my $algorithm;
    my $hash_found = 0;

    # Auto-detect hash algorithm based on length
    if    (length($hash) == 32)  { $algorithm = 'MD5'; }
    elsif (length($hash) == 40)  { $algorithm = 'SHA1'; }
    elsif (length($hash) == 64)  { $algorithm = 'SHA256'; }
    else { 
        print "[!] Unknown hash format: $hash (length: " . length($hash) . ")\n"; 
        next; 
    }

    print "[*] Processing $algorithm hash: $hash\n";

    foreach my $word (@dictionary) {
        my $computed;

        if    ($algorithm eq 'MD5')    { $computed = md5_hex($word); }
        elsif ($algorithm eq 'SHA1')   { $computed = sha1_hex($word); }
        elsif ($algorithm eq 'SHA256') { $computed = sha256_hex($word); }

        if ($computed eq $hash) {
            my $result = "[+] CRACKED: $hash = $word";
            print "$result\n";
            push @cracked_results, "$hash = $word";
            $cracked_count++;
            $hash_found = 1;
            last; # Move to next hash once cracked
        }
    }

    if (!$hash_found) {
        print "[-] FAILED: $hash\n";
        push @failed_hashes, $hash;
        $failed_count++;
    }
}

my $end_time = time();
my $duration = $end_time - $start_time;

print "\n";

# Save results to file
if (@cracked_results) {
    open(my $results_fh, '>', 'cracked.txt') or die "Cannot create cracked.txt: $!";
    foreach my $result (@cracked_results) {
        print $results_fh "$result\n";
    }
    close($results_fh);
}

# Display enhanced statistics
my $total_hashes = scalar(@hashes);
my $success_rate = $total_hashes > 0 ? ($cracked_count / $total_hashes * 100) : 0;

printf "✅ Cracked: %d / %d hashes\n", $cracked_count, $total_hashes;
printf "❌ Failed: %d\n", $failed_count;
printf "📊 Success Rate: %.1f%%\n", $success_rate;
printf "🕒 Total Time Taken: %.2f sec\n", $duration;

if (@cracked_results) {
    print "\n💾 Results saved to cracked.txt\n";
}

print "\n[*] Done.\n";
perl script.plperl script.pl hashes.txt