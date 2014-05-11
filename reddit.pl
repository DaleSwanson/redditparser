#!/usr/bin/perl
#reddit parser by Stephen Wetzel Aug 30 2013
#requires gnuplot

use strict;
use warnings;
use autodie;
use Cwd 'abs_path';
use Date::Calc qw(:all);
use Statistics::Basic qw(:all nofill);

abs_path($0) =~ m/(.*\/)/;
my $dir = $1; #directory path of script
#$|++; #autoflush disk buffer


my $sub = 'http://www.reddit.com/r/AskScienceDiscussion/new/'; #url for subreddit, blank to grab from command line
if (!$sub) {$sub = $ARGV[0];}
my $linxdump = 'reddit.html';
my $outfile = 'reddit.'.time.'.csv';
my $debug=0;
my $maxpostlimit = 100; #stop getting posts after this limit

my $temp;
my $reachedend = 0; #flag, set to 1 when we hit the last post
my $url = $sub;
my $totalposts = 0;
my @postscores; #post scores
my @posthours; #post hours
my @postdows; #post day of week
my @postdates; #formated dates
my %mon2num = qw(Jan 01 Feb 02 Mar 03 Apr 04 May 05 Jun 06 Jul 07 Aug 08 Sep 09 Oct 10 Nov 11 Dec 12);
my %dow2num = qw(Sun 1 Mon 2 Tue 3 Wed 4 Thu 5 Fri 6 Sat 7);

my @postsinhour;
my @postsinday;

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
		while ($filecontents =~ m/<div class="score unvoted">(\S+)<\/div>/g) 
		{#find score data
			my $score = $1;
			$score =~ s/\D//g;
			if (!$score) {$score=0;}
			$totalposts++; #a running count of all posts, does not reset
			print "\nScore: $score";
			push(@postscores, $score);
		}
		#submitted&#32;<time title="1   2   3 4 :5 :6  7    UTC" datetime="2013-08-07T13:04:25-07:00">23 days</time>
		#submitted&#32;<time title="Wed Aug 7 20:04:25 2013 UTC" datetime="2013-08-07T13:04:25-07:00">23 days</time>
		while ($filecontents =~ m/submitted&#32;<time title=\"(\w{3}) (\w{3}) (\d{1,2}) (\d{2}):(\d{2}):(\d{2}) (\d{4}) UTC\" datetime/g)
		{#find time data
			push(@posthours, $4);
			push(@postdows, $dow2num{$1});
			$temp = "$7;".$mon2num{$2}.";$3;$4;$5;$6;".$dow2num{$1};
			push(@postdates, $temp);
			#$dow = Day_of_Week($1,$2,$3);
			print "\nDate: $7-$2-$3 $4:$5:$6 \t$1";
		}
		
		if ($filecontents =~ m/<a href=\"(\S+)\" rel=\"nofollow next\" >/)
		{#find next page url
			$url = $1;
			if (!$debug) {$reachedend=0;}
		}
	}
	print "\nPosts: $totalposts";
	if ($totalposts >= $maxpostlimit) {$reachedend=1;}
} until ($reachedend);

#now we have all the data


open my $ofile, '>', $outfile;
print $ofile "Score;Year;Month;Day;Hour;Min;Sec;DOW";
print "\n\nOverall Median: ".median(@postscores);

for (my $i=0; $i<$totalposts; $i++)
{#go through data and process
	print $ofile "\n$postscores[$i];$postdates[$i]";
	
}

for (my $hour=0; $hour <= 23; $hour++)
{
	my @temparray;
	for (my $i=0; $i<$totalposts; $i++)
	{#go through data and process
		if ($posthours[$i] == $hour)
		{
			$postsinhour[$hour]++;
			push(@temparray, $postscores[$i]);
		}
		
	}
	print "\nHour: $hour";
	print "\tPosts: $postsinhour[$hour]";
	print "\tMedian Score: ".median(@temparray);
}

for (my $day=1; $day <= 7; $day++)
{
	my @temparray;
	for (my $i=0; $i<$totalposts; $i++)
	{#go through data and process
		if ($postdows[$i] == $day)
		{
			$postsinday[$day]++;
			push(@temparray, $postscores[$i]);
		}
		
	}
	print "\nDay: $day";
	print "\tPosts: $postsinday[$day]";
	print "\tMedian Score: ".median(@temparray);
}

close $ofile;



print "\nDone\n\n";
