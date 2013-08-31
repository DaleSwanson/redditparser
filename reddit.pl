#!/usr/bin/perl
#reddit parser by Dale Swanson Aug 30 2013
#requires gnuplot

use strict;
use warnings;
use autodie;
use Cwd 'abs_path';
abs_path($0) =~ m/(.*\/)/;
my $dir = $1; #directory path of script
#$|++; #autoflush disk buffer


my $sub = 'http://www.reddit.com/r/dataisbeautiful/top/?sort=top&t=month'; #url for subreddit, blank to grab from command line
if (!$sub) {$sub = $ARGV[0];}
my $linxdump = 'reddit.html';
my $debug=0;

my $temp;
my $reachedend = 0; #flag, set to 1 when we hit the last post
my $url = $sub;
my $postcount = 0;
my @scores; #post scores
my @hours; #post hours


do
{ 
	print "\nURL: $url";
	$reachedend=1;
	#wget "http://www.reddit.com/r/dataisbeautiful/top/?sort=top&t=month" -O -  >reddit.txt
	$temp = "wget \"$url\" -O -  >\"$linxdump\""; #get band top songs
	#print "\n$temp\n";
	if (!$debug) {system($temp);} #download page when not debug
	if ($debug) {$linxdump = "dump.txt";} #if debug use saved page
	
	open my $ifile, '<', $linxdump;
	
	while (my $filecontents = <$ifile>) {
		$postcount=0;
		while ($filecontents =~ m/<div class="score likes">(\d+)<\/div>/g) {
			$postcount++;
			print "\nScore: $1";
			$scores[$postcount] = $1;
			
		}
		$postcount=0;
		while ($filecontents =~ m/datetime=\"(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)-(\d+):(\d+)\"/g) {
			$postcount++;
			#print "\tHour: $4";
			$hours[$postcount] = $4;
			
		}
		
		if ($filecontents =~ m/<a href=\"(\S+)\" rel=\"nofollow next\" >/)
		{
			$url = $1;
			$reachedend=0;
		}
		
		
	}
	
	
	#$reachedend=1;
	
} until ($reachedend);





print "\nDone\n\n";
