#! /usr/bin/perl

# Script takes a list of s[ecoes abbreviations, a KEGG code for a reference organism,
# retrieves a list of enzymes the reference organism possesses,
# and prints out their counts
#
# Author: Maria Persico
# 
# This software is distributed under open-source license
# with no liability accepted for any loss or damage arising from the use of the script.
# The code can be re-destributed and altered
# with the acknowledgement of the original source.

use strict;
use lib '/usr/local/share/perl/5.20.2';
#use lib qw(./modulos/share/perl/5.8.8/);
#use lib qw(./PerlModules/share/perl/5.24.1/);
use LWP::Simple;
#use Text::NSP::Measures::2D::Fisher::twotailed;
#use Statistics::Multtest qw(:all);

use POSIX qw(strftime);

my $date = strftime "%m_%d_%Y", localtime;
#print $date"";

my $content;
my $org = $ARGV[0];
#my %ko_counts;

my $k;
my $v;

my $input_file1=$ARGV[0];

open(FILECONTENT, "< $input_file1");

my $counter= 0;

while (!eof(FILECONTENT))
{

###

my          $line=<FILECONTENT>;
            chomp $line;

eval {$content = get("http://rest.kegg.jp/link/$line/ko");
#if (!$content) {
 #       die "Failed to download enzymes for the organism $line!";
#}

if($@) {
  # In case you want to deal with the error; $@ contains the text describing the error
print "Failed to download enzymes for the organism $line!";
#break;
next;

}else {
print "fetch from KEGG info on $line\n";
my %ko_counts;
my $fileName = $date . '_' . $line;
system("wget -qO- http://rest.kegg.jp/link/$line/ko > $fileName");

        my @data = split "\n", $content;

                for my $line2 (@data) {
              
                my @data1 = split ' ', $line2;

                if ($data1[0] =~ /^ko\:/) {

                my @data2 = split ':', $data1[0];

                if (!exists $ko_counts{$data2[1]}){

                       $ko_counts{$data2[1]} = 1;

                }elsif(exists $ko_counts{$data2[1]}){

                       $ko_counts{$data2[1]} += 1;
                } 
        }else{next;}
        
}

my $output_file1=$line . '.txt';
    
if (-e $output_file1) 
{ 
    #file exists - delete to avoid duplicated info that make the counts meaningless

unlink $output_file1 or warn "Could not unlink $output_file1: $!";

}

open(F_OUT, ">>$output_file1") || die "non posso aprire $output_file1\n";

#genes-enzymes count for the given organism

while ( ($k,$v) = each %ko_counts ) {
print F_OUT "$k\t$v\n";
#print "$k => $v\n"; 
}


}

close F_OUT;

}# end of eval?
}
close FILECONTENT;
