#!usr/bin/perl
use warnings; use strict;
use LWP::Simple;

################################
my $stockNO;
my @stockNum;
my $yearmonth;
my $url;
my $yearmonthday;
my @input_0;
my @input_1;
my @input_2;
my @input_3;
my @input_4;
my @all;
my @all_2;
my @all_3;
my ($yearstart,$yearend);
my ($monthstart, $monthend);
my $sleepinterval;
my $stock_exist;
my $year_east;
my $haveit;

################################
$stockNO = 2330;
$yearstart = $ARGV[0];	$yearend = $ARGV[1];
$monthstart = $ARGV[2];	 $monthend = $ARGV[3];
#$yearstart = 2016;	$yearend = 2016;
#$monthstart = 8;	 $monthend = 10;
$sleepinterval = 1;

################################ open_file,"<test_0
open (open_file,"<stock_number.txt") or die "open file error : $!";
	@stockNum = <open_file>;
close open_file;

################################
#forloop_1: for (my $year = $yearstart; $year <= $yearend; $year++){
for (my $year = $yearstart; $year <= $yearend; $year++){
	for (my $month = $monthstart; $month <= $monthend; $month++){
		for (my $k=0; $k<$#stockNum+1; $k++) {
			$stockNO = $stockNum[$k];
			$stockNO =~ s/\n//g;

			$year_east = $year - 1911;
			if ($month>=10){
				$yearmonth = "$year $month 01";
				$yearmonth =~ s/ //g;
			}else{
				$yearmonth = "$year 0 $month 01";
				$yearmonth =~ s/ //g;
			}
			
			$url = "http://www.tse.com.tw/exchangeReport/STOCK_DAY".
				"?response=html&date= $yearmonth &stockNo= $stockNO";
			$url =~ s/ //g;
			
			$stock_exist = get_url_data ($url, $sleepinterval, $yearmonth, $stockNO); #submodule
			
			if ($stock_exist == 0) {
				my $locatime = localtime();
				print  "There is no ", $stockNO," table @", $locatime, "\n"; 
			};

			if ($stock_exist == 1){
			
				################################ open_file,"<test_0
				open (open_file,"<test_0_$stockNO.txt") or die "open file error : $!";
					@input_0 = <open_file>;
				close open_file;
				
				################################ write_file,">test_1
				open (write_file,">test_1_$stockNO.txt") or die "open file error : $!";
				#foreach (@input) { print "\n $_ ";}
				for (my $i=0; $i<$#input_0+1; $i++) {
					if ($input_0[$i] =~ /<td>/) {	print write_file ($input_0[$i], "\n");};
				}
				close write_file;
				
				################################ open_file,"<test_1
				open (open_file,"<test_1_$stockNO.txt") or die "open file error : $!";
					@input_1 = <open_file>;
				close open_file;

				################################ write_file,">skill
				open (write_file,">>skill_tmp_$stockNO.txt") or die "open file error : $!";						
					seek (write_file,0,2);
					
					for (my $day = 1; $day <= 31; $day++){
						if ($month>=10){
							$yearmonth = "$year_east/ $month";
							$yearmonth =~ s/ //g;
						}else{
							$yearmonth = "$year_east/ 0 $month";
							$yearmonth =~ s/ //g;
						}
						if ($day>=10){
							$yearmonthday = "$yearmonth/ $day";
							$yearmonthday =~ s/ //g;
						}else{
							$yearmonthday = "$yearmonth/ 0 $day";
							$yearmonthday =~ s/ //g;
						}

						for (my $i=0; $i<$#input_1+1; $i++){
							$input_1[$i]=~ s/<td>//g;
							$input_1[$i]=~ s/<\/td>//g;
							if ($input_1[$i] =~ $yearmonthday){	
								for (my $j=0; $j<=16; $j+=2){
									$input_1[$i+$j]=~ s/<td>//g;
									$input_1[$i+$j]=~ s/<\/td>//g;	
									$input_1[$i+$j]=~ s/\n//g;
									
									print write_file ($input_1[$i+$j],"\t\t");	
								
									if ($j == 16){
										print write_file ("\n");
									};
								};
							};
						};
					};
				close write_file;
				
				################################ do_cmp_test_1_with_skill
				open (open_file,"<skill_tmp_$stockNO.txt") or die "open file error : $!";
					@input_2 = <open_file>;
				close open_file;		
				
				if (-e "$stockNO\_skill.txt"){					
					open (open_file,"<$stockNO\_skill.txt") or die "open file error : $!";
						@input_3 = <open_file>;
					close open_file;				
					
					for (my $i=0; $i<$#input_2+1; $i++){
						for (my $j=0; $j<$#input_3+1; $j++){
							@all_2 = split('\t\t' , $input_2[$i]);
							@all_3 = split('\t\t' , $input_3[$j]);
							$all_2[0] =~ s/\///g;
							$all_3[0] =~ s/\///g;
							if($all_2[0] == $all_3[0]) {
							$haveit = 1; };
						};

						if ($haveit == 0){
							print "Update\t";
							open (write_file,">>$stockNO\_skill.txt") or die "open file error : $!";						
								seek (write_file,0,2);
								printf write_file ("%15s", $input_2[$i]);
							close write_file;
						};
						$haveit = 0;
					};	
				}else{	
					print "File is not exist.\n";
					open (write_file,">$stockNO\_skill.txt") or die "open file error : $!";					
						foreach (@input_2) { printf write_file"%15s","$_"; };
					close write_file;					
				};
			

			open (open_file,"<$stockNO\_skill.txt") or die "open file error : $!";
				@input_4 = <open_file>;
			close open_file;
			open (write_file,">$stockNO\_skill.txt") or die "open file error : $!";					
				foreach (@input_4) { 
					$_ =~ 	s/\///g; 
					print write_file $_;
				};
			close write_file;		
			
			system "del test_0_$stockNO.txt";
			system "del test_1_$stockNO.txt";
			system "del skill_tmp_$stockNO.txt";
			#system "rm -fr test_0_$stockNO.txt";
			#system "rm -fr test_1_$stockNO.txt";		
			};
		};	
	};
};	
	

	

################################
print "\n\n ~~~~ History_tse => All works have been done! ~~~~ \n\n";

=header	
	################################ write_file,">skill
	if ($first_loop == 1){
		open (open_file,"<skill_$stockNO.txt") or die "open file error : $!";
			@input_2 = <open_file>;
		close open_file;		
		
		open (write_file,">skill_$stockNO.txt") or die "open file error : $!";
			print write_file ("NO=",$stockNO,"\t\t","成交股數\t\t","成交金額\t\t");	
			print write_file ("開盤價  \t\t","最高價  \t\t","最低價  \t\t");	
			print write_file ("收盤價  \t\t","漲跌價差\t\t","成交筆數\n");
			foreach (@input_2){print write_file "$_"; };
		close write_file;
		$first_loop = 0;
	};
=cut	






=header
################## Start reading parameters ####################################
open (open_file, "<mem_try_input_parameter.v") or die "open file error : $!";
	@input = <open_file>;
close open_file;
foreach (@input) { print "\n $_ ";}
for ($i=0; $i<$#input+1; $i++) {
	@all = split(' ' , $input[$i]);
	#for ($k=2; $k<$#all+1; $k+=3){print $all[$k], "\n";}
	if ($all[0] =~ /WORD_WIDTH/) {$WORD_WIDTH = $all[2];};
	if ($all[0] =~ /ADDRX_END/) {$ADDRX_END = $all[2];};
	if ($all[0] =~ /ADDRY_END/) {$ADDRY_END = $all[2];};
	if ($all[0] =~ /MEM_QUOTA/) {$MEM_QUOTA = $all[2];};
	if ($all[0] =~ /Total_bank/) {$Total_bank = $all[2];};
	if ($all[0] =~ /Sub_bank/) {$Sub_bank = $all[2];};
	if ($all[0] =~ /Latch_wr_req_dly_cycle/) {$Latch_wr_req_dly_cycle = $all[2];};
	if ($all[0] =~ /Latch_dp_req_dly_cycle/) {$Latch_dp_req_dly_cycle = $all[2];};
}
######################## End of reading parameters ####################################
=cut

=header
system "gvim mem_try_output.v";
print "\n ~~~~ All works have been done! ~~~~ \n\n";
=cut

=header
open (write_file,">>test_0_$stockNO_in.txt") or die "open file error : $!";
	seek (write_file,0,2);
	print write_file ($getdoc);
close write_file;
=cut

sub get_url_data {
	my ($url_in, $sleepinterval_in, $yearmonth_in, $stockNO_in) = @_;
	my ($stock_exist_out);
	my ($getdoc, $datestring);
	
	################################ wait until get data
	whileloop_1: while (1){
		$getdoc = get $url_in;
		$getdoc =~ s/ //g;
		sleep($sleepinterval_in);
		if ($getdoc =~ /<div>/ ){ last whileloop_1; };
	};

	################################ write data to test_0
	if ($getdoc =~ /<table>/ ){
		
		open (write_file,">test_0_$stockNO_in.txt") or die "open file error : $!";
			print write_file ($getdoc);
		close write_file;
		
		$datestring = localtime();
		print  "$url\n";
		print  "$yearmonth_in : fetch time $datestring\n";
		$stock_exist_out = 1;
	}else{
		$stock_exist_out = 0;
	};
	return $stock_exist_out;
};

=header
 Code  Issues 0  Pull requests 0  Projects 0  Wiki  Settings Insights 
Branch: master Find file Copy pathperl_stock/History
ee6f7aa  a day ago
@b9907020 b9907020 Update History
1 contributor
RawBlameHistory     
314 lines (260 sloc)  8.28 KB
Contact GitHub API Training Shop Blog About
© 2017 GitHub, Inc. Terms Privacy Security Status Help
#1.$stockNO
#2.$year
#3.$month
#4.day
#5.$sleepinterval
#6.$first_loop
=cut
