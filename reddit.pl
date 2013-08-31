#!/usr/bin/perl
#reddit parser by Dale Swanson Aug 30 2013
#requires gnuplot

use strict;
use warnings;
use autodie;
use Cwd 'abs_path';
use Date::Calc qw(:all);


abs_path($0) =~ m/(.*\/)/;
my $dir = $1; #directory path of script
#$|++; #autoflush disk buffer


my $sub = 'http://www.reddit.com/r/dataisbeautiful/new/'; #url for subreddit, blank to grab from command line
if (!$sub) {$sub = $ARGV[0];}
my $linxdump = 'reddit.html';
my $outfile = 'reddit.'.time.'.csv';
my $debug=0;
my $maxpostlimit = 22; #stop getting posts after this limit

my $temp;
my $reachedend = 0; #flag, set to 1 when we hit the last post
my $url = $sub;
my $totalposts = 0;
my @postscores; #post scores
my @posthours; #post hours
my @postdows; #post day of week
my %mon2num = qw(Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06 Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12);
my %dow2num = qw(Sun 1 Mon 2 Tue 3 Wed 4 Thu 5 Fri 6 Sat 7);

do
{#grab each page of sub, get post data from each
	print "\nURL: $url";
	$reachedend=1; #assume last page unless we find next link
	#wget "http://www.reddit.com/r/dataisbeautiful/top/?sort=top&t=month" -O -  >reddit.txt
	$temp = "wget \"$url\" -O -  >\"$linxdump\""; #get band top songs
	#print "\n$temp\n";
	if (!$debug) {system($temp);} #download page when not debug
	if ($debug) {$linxdump = "dump.txt";} #if debug use saved page
	
	open my $ifile, '<', $linxdump;
	while (my $filecontents = <$ifile>) 
	{#go through reddit dump, grab post data
		while ($filecontents =~ m/<div class="score likes">(\d+)<\/div>/g) 
		{#find score data
			$totalposts++; #a running count of all posts, does not reset
			print "\nScore: $1";
			push(@postscores, $1);
		}
		#submitted&#32;<time title="1   2   3 4 :5 :6  7    UTC" datetime="2013-08-07T13:04:25-07:00">23 days</time>
		#submitted&#32;<time title="Wed Aug 7 20:04:25 2013 UTC" datetime="2013-08-07T13:04:25-07:00">23 days</time>
		while ($filecontents =~ m/submitted&#32;<time title=\"(\w{3}) (\w{3}) (\d{1,2}) (\d{2}):(\d{2}):(\d{2}) (\d{4}) UTC\" datetime/g)
		{#find time data
			push(@posthours, $4);
			push(@postdows, $dow2num{$1});
			#$dow = Day_of_Week($1,$2,$3);
			print "\nDate: $7-$2-$3 $4:$5:$6 \t$1";
		}
		
		if ($filecontents =~ m/<a href=\"(\S+)\" rel=\"nofollow next\" >/)
		{#find next page url
			$url = $1;
			if (!$debug) {$reachedend=0;}
		}
	}
	if ($totalposts >= $maxpostlimit) {$reachedend=1;}
} until ($reachedend);

#now we have all the data


open my $ofile, '>', $outfile;
print $ofile "Score;Hour;DOW";

for (my $i=0; $i<$totalposts; $i++)
{#go through data and process
	print $ofile "\n$postscores[$i];$posthours[$i];$postdows[$i]";
	
	
	
	
	
}


close $ofile;











print "\nDone\n\n";
