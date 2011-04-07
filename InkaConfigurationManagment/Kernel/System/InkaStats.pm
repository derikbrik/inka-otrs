#--
#Kernel/System/InkaStats.pm - core module for Reports (Stats)
# Copyright (C) 2011 Juan Manuel Rodriguez
#--
#$Id: InkaStats.pm
#--
#This software comes with ABSOLUTELY NO WARRANTY. For details, see
#the enclosed file COPYING for license information (AGPL). If you
#did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
#--
package Kernel::System::InkaStats;
use strict;
use warnings;

use Kernel::System::InkaStatsCtes;
use Kernel::System::DB;
use Digest::MD5 qw(md5);
use Time::Local;

sub new {
	my ( $Type, %Param ) = @_;
	#allocate new hash for object
	my $Self = {};
	bless ($Self, $Type);

	# check needed objects
    for (qw(DBObject ConfigObject LogObject TimeObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }
	return $Self;
}

=item CIxCategoryReport()

Returns the information for the report: "CIxCategoryReport" 

Params:
	none

Invocation:
    my @ci = $Object->CIxCategoryReport();
    
Return:
	An array with the following information for the report:
		([$Title],[@HeadData], @Data);

=cut
sub CIxCategoryReport(){

	my ( $Self, %Param ) = @_;
	my @HeadData = ();
	my @RowData = ();
	my %HeadDataPos = ();
	my %RowDataPos = ();
	my @Data = ();
	
	my $SQLColumns = Kernel::System::InkaStatsCtes::GET_CATEGORIES_QUERY;	
	my $SQLRows    = Kernel::System::InkaStatsCtes::GET_STATE_QUERY;
	my $SQLMain    = Kernel::System::InkaStatsCtes::REPORT_01_MAIN_QUERY;
	my $title      = Kernel::System::InkaStatsCtes::REPORT_01_TITLE;
	
	push(@HeadData, 'State');
	
	##Get the columns
	$Self->{DBObject}->Prepare(SQL => $SQLColumns);
	my $k = 0;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		push(@HeadData, $Row[1]);
 		$HeadDataPos{$Row[0]} = $k;
 		$k++; 
	}
	
	##Get the First Row name
	$Self->{DBObject}->Prepare(SQL => $SQLRows);
	my $z = 0;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		push(@RowData, $Row[1]);
 		$RowDataPos{$Row[0]} = $z;
 		$z++; 
	}
	
	##Complete with empty Data	
	for(my $i = 0; $i < @RowData; $i++) {
			my @SubData = ();
			$Data[$i] = \@SubData;
			$Data[$i][0] = $RowData[$i];
			for(my $j = 0; $j < @HeadData; $j++) {
				$Data[$i][$j+1] = '0';
			}
	}
	
	##Execute Main QUery
	$Self->{DBObject}->Prepare(SQL => $SQLMain);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		$Data[$RowDataPos{$Row[2]}][$HeadDataPos{$Row[1]}+1] = $Row[0];
	}
		
	return ([$title],[@HeadData], @Data);
}

=item CICreatedxMonthAndCategory()

Returns the information for the report: "InkaCICreatedxMonthCategory" (Configuration items created in a selected month per category) 

Params:
	 year : four digint integer 
	 month: 0 to 11 digit
	 dateType: String #could be "acquisition_day" or "creation_date"

Invocation:    
    $Self->{StatsObject}->CICreatedxMonthAndCategory( year => '2011', month => 1, dateType=> 'acquisition_day')
    
Return:
	An array with the following information for the report:
		([$Title],[@HeadData], @Data);

=cut
sub CICreatedxMonthAndCategory(){
	
	my ( $Self, %Param ) = @_;
	my @ColumnData = ();
	my @RowData = ();
	my %RowDataPos = ();
	my @Data = ();
	my @Numbers = ();
	my $year = $Param{year};
	my $month = $Param{month};
	my $dateType = $Param{dateType};
	my $tipeSelectedStr = "";
	
	my $SQLRows = Kernel::System::InkaStatsCtes::GET_CATEGORIES_QUERY;
	my $SQL = '';
	my $SQLMain = '';
	if($dateType eq 'creation_date'){
		$SQLMain = Kernel::System::InkaStatsCtes::REPORT_02_MAIN_QUERY_00;
		$tipeSelectedStr = "created";
	}else{
		$SQLMain = Kernel::System::InkaStatsCtes::REPORT_02_MAIN_QUERY_01;
		$tipeSelectedStr = "acquired";
	}
	my $title      = sprintf(Kernel::System::InkaStatsCtes::REPORT_02_TITLE, $tipeSelectedStr)." ($month / $year)" ;
	
	@ColumnData = $Self->calendar(year => $year, month=> ($month-1), onlyNumbers =>0);
	@Numbers = $Self->calendar(year => $year, month=> ($month-1), onlyNumbers =>1);
	unshift(@ColumnData, 'Category');
	
	##Get the columns
	$Self->{DBObject}->Prepare(SQL => $SQLRows);
	my $k = 0;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		push(@RowData, $Row[1]);
 		$RowDataPos{$Row[0]} = $k;
 		$k++;
	}

	##Complete with empty Data	
	for(my $i = 0; $i < @RowData; $i++) {
			my @SubData = ();
			$Data[$i] = \@SubData;
			$Data[$i][0] = $RowData[$i];
			for(my $j = 0; $j < @ColumnData; $j++) {
				$Data[$i][$j+1] = '0';
			}
	}
	
	my $nextDay = '';
	my $today = '';
	for(my $j = 0; $j < @Numbers; $j++){
		if($j!=0){
			$SQL .= " UNION \n";	
		}
		$Numbers[$j] = $Self->trim(string =>$Numbers[$j]);
		if($j == (@Numbers-1)){
			if($month!=12){
				$nextDay = '01/'.($month+1).'/'.$year;
			}else{
				$nextDay = '01/01/'.($year+1);
			}
		}else{
			$nextDay = ($Numbers[$j]+1).'/'.$month.'/'.$year;
		}
		$today = $Numbers[$j].'/'.$month.'/'.$year;
		$SQL .= sprintf($SQLMain, $Numbers[$j], $Self->convertDateToLongInt( 'date' => $today), $Self->convertDateToLongInt( 'date' => $nextDay));
	}
		
	##Execute Main QUery
	$Self->{DBObject}->Prepare(SQL => $SQL);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		$Data[$RowDataPos{$Row[1]}][$Row[2]] = $Row[0];
	}
		
	return ([$title],[@ColumnData], @Data);
	
}


=item CICreatedxMonthAndState()

Returns the information for the report: "InkaCICreatedxMonthState" (Configuration items created in a selected month per state) 

Params:
	 year : four digint integer 
	 month: 0 to 11 digit
	 dateType: String #could be "acquisition_day" or "creation_date"

Invocation:    
    $Self->{StatsObject}->CICreatedxMonthAndCategory( year => '2011', month => 1, dateType=> 'acquisition_day')
    
Return:
	An array with the following information for the report:
		([$Title],[@HeadData], @Data);

=cut
sub CICreatedxMonthAndState(){
	
	my ( $Self, %Param ) = @_;
	my @ColumnData = ();
	my @RowData = ();
	my %RowDataPos = ();
	my @Data = ();
	my @Numbers = ();
	my $year = $Param{year};
	my $month = $Param{month};
	my $dateType = $Param{dateType};
	my $tipeSelectedStr = "";
	
	my $SQLRows = Kernel::System::InkaStatsCtes::GET_STATE_QUERY;
	my $SQL = '';
	my $SQLMain = '';
	if($dateType eq 'creation_date'){
		$SQLMain = Kernel::System::InkaStatsCtes::REPORT_03_MAIN_QUERY_00;
		$tipeSelectedStr = "created";
	}else{
		$SQLMain = Kernel::System::InkaStatsCtes::REPORT_03_MAIN_QUERY_01;
		$tipeSelectedStr = "acquired";
	}
	my $title      = sprintf(Kernel::System::InkaStatsCtes::REPORT_03_TITLE, $tipeSelectedStr)." ($month / $year)" ;
	
	@ColumnData = $Self->calendar(year => $year, month=> ($month-1), onlyNumbers =>0);
	@Numbers = $Self->calendar(year => $year, month=> ($month-1), onlyNumbers =>1);
	unshift(@ColumnData, 'State');
	
	##Get the columns
	$Self->{DBObject}->Prepare(SQL => $SQLRows);
	my $k = 0;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		push(@RowData, $Row[1]);
 		$RowDataPos{$Row[0]} = $k;
 		$k++;
	}

	##Complete with empty Data	
	for(my $i = 0; $i < @RowData; $i++) {
			my @SubData = ();
			$Data[$i] = \@SubData;
			$Data[$i][0] = $RowData[$i];
			for(my $j = 0; $j < @ColumnData; $j++) {
				$Data[$i][$j+1] = '0';
			}
	}
	
	my $nextDay = '';
	my $today = '';
	for(my $j = 0; $j < @Numbers; $j++){
		if($j!=0){
			$SQL .= " UNION \n";	
		}
		$Numbers[$j] = $Self->trim(string =>$Numbers[$j]);
		if($j == (@Numbers-1)){
			if($month!=12){
				$nextDay = '01/'.($month+1).'/'.$year;
			}else{
				$nextDay = '01/01/'.($year+1);
			}
		}else{
			$nextDay = ($Numbers[$j]+1).'/'.$month.'/'.$year;
		}
		$today = $Numbers[$j].'/'.$month.'/'.$year;
		$SQL .= sprintf($SQLMain, $Numbers[$j], $Self->convertDateToLongInt( 'date' => $today), $Self->convertDateToLongInt( 'date' => $nextDay));
	}
		
	##Execute Main QUery
	$Self->{DBObject}->Prepare(SQL => $SQL);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		$Data[$RowDataPos{$Row[1]}][$Row[2]] = $Row[0];
	}
		
	return ([$title],[@ColumnData], @Data);
	
}

=item CIxCategoryDateReport()

Returns the information for the report: "CIxCategoryDateReport" 

Params:
	startDate: string #like '01/01/2011'
	endDate: string   #like '01/01/2011'
	dateType: String  #could be "acquisition_day" or "creation_date"

Invocation:
    my @ci = $Object->CIxCategoryDateReport(startDate => '01/01/2011', endDate   => '01/01/2011', dateType=>'acquisition_day');
    
Return:
	An array with the following information for the report:
		([$Title],[@HeadData], @Data);

=cut
sub CIxCategoryDateReport(){

	my ( $Self, %Param ) = @_;
	my @HeadData = ();
	my @RowData = ();
	my %HeadDataPos = ();
	my %RowDataPos = ();
	my @Data = ();
	my $tipeSelectedStr = '';
	my $startDate = $Param{startDate};
	my $endDate   = $Param{endDate};
	my $dateType  = $Param{dateType};
	
	my $SQLColumns = Kernel::System::InkaStatsCtes::GET_CATEGORIES_QUERY;	
	my $SQLRows    = Kernel::System::InkaStatsCtes::GET_STATE_QUERY;
	my $SQLMain    = '';
	
	
	if($dateType eq 'creation_date'){
		$SQLMain = Kernel::System::InkaStatsCtes::REPORT_04_MAIN_QUERY_00;
		$tipeSelectedStr = "created";
	}else{
		$SQLMain = Kernel::System::InkaStatsCtes::REPORT_04_MAIN_QUERY_01;
		$tipeSelectedStr = "acquired";
	}
	my $title = sprintf(Kernel::System::InkaStatsCtes::REPORT_04_TITLE, $tipeSelectedStr)." ($startDate - $endDate)" ;

	push(@HeadData, 'State');
	##Get the columns
	$Self->{DBObject}->Prepare(SQL => $SQLColumns);
	my $k = 0;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		push(@HeadData, $Row[1]);
 		$HeadDataPos{$Row[0]} = $k;
 		$k++;
	}

	##Get the First Row name
	$Self->{DBObject}->Prepare(SQL => $SQLRows);
	my $z = 0;
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		push(@RowData, $Row[1]);
 		$RowDataPos{$Row[0]} = $z;
 		$z++;
	}

	##Complete with empty Data
	for(my $i = 0; $i < @RowData; $i++) {
			my @SubData = ();
			$Data[$i] = \@SubData;
			$Data[$i][0] = $RowData[$i];
			for(my $j = 0; $j < @HeadData; $j++) {
				$Data[$i][$j+1] = '0';
			}
	}

	##Execute Main Query
	my $startDateNumber = $Self->convertDateToLongInt( 'date' => $startDate);
	my $endDateNumber   = $Self->convertDateToLongInt( 'date' => $endDate);	
	$Self->{DBObject}->Prepare(SQL => $SQLMain, Bind => [\$startDateNumber, \$endDateNumber]);
	while (my @Row = $Self->{DBObject}->FetchrowArray()) {
 		$Data[$RowDataPos{$Row[2]}][$HeadDataPos{$Row[1]}+1] = $Row[0];
	}
	
	return ([$title],[@HeadData], @Data);
}

=item calendar()

Returns array of days with number and name   

Params:
	year: string like '2011' 
	month: number 0 to 11
	onlyNumbers: 1 or 0 # if cero will show the name of the day also

Invocation:
   @array = $Self->calendar(2011, 0) # 0 january
    
Return:
	 [
            'Tue \n    1',
            'Wed \n    2',....
            'Mon \n   28'
          ]


=cut
sub calendar {
	my ( $Self, %Param ) = @_;
	my $year = $Param{year};
	my $month = $Param{month};
	my $onlyNumbers = $Param{onlyNumbers};
	
	unless($onlyNumbers){
		$onlyNumbers = 0;
	}
	
	my @mon_days = qw/31 28 31 30 31 30 31 31 30 31 30 31/;
	++$mon_days[1] if $year % 4 == 0 && ($year % 400 == 0 || $year % 100 != 0);
	my @Data = ();	
	my @calDays = qw(Sun Mon Tue Wed Thu Fri Sat);
	my $cal = "";
	
	# Months are indexed beginning at 0
	my $time = timegm(0,0,0,1,$month,$year);
	my $wday = (gmtime $time)[6];
		
	my $mday = 1;
	my $j=0;
	my $k = $wday;
	
	 
	while ($mday <= $mon_days[$month]) {
		
		my $aux = ($k % @calDays);
		$Data[$j]= '';
		if($onlyNumbers != 1){
			$Data[$j] = $calDays[$aux]."\n";
		}
		$Data[$j] .= sprintf "%4s", $mday++;
		$j++;
		$k++;	
	}
	return @Data;
}

#Paramas: 'date' : string in format: dd/mm/yyyy
# returns: LONGINT (SO timestamp)
sub convertDateToLongInt(){
	my ( $Self, %Param ) = @_;	
	my $date = $Param{date};
	if($date==0 || $date eq '0' ){
	 	return 0;	
	}
	my ($dd, $mm, $yy) = split(/\//, $date);
	my $strDate = $yy.'-'.$mm.'-'.$dd.' 00:00:01';
	return $Self->{TimeObject}->TimeStamp2SystemTime(String => $strDate);
}

# Paramas: 'string' : string
# returns: string
sub trim()
{
  my ( $Self, %Param ) = @_;	
  my $string = $Param{string};
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}

1;