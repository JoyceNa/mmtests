# Monitor.pm
#
# This is base class description for modules that parse MM Tests directories
# and extract from the monitors

package MMTests::Monitor;

use MMTests::PrintGeneric;
use MMTests::PrintHtml;
use constant MONITOR_CPUTIME_SINGLE	=> 1;
use constant MONITOR_VMSTAT		=> 2;
use constant MONITOR_PROCVMSTAT		=> 3;
use constant MONITOR_NUMA_CONVERGENCE	=> 4;
use constant MONITOR_NUMA_USAGE		=> 5;
use constant MONITOR_TOP		=> 6;
use constant MONITOR_LATENCY		=> 7;
use constant MONITOR_IOSTAT		=> 8;
use constant MONITOR_FTRACE		=> 9;
use constant MONITOR_IOTOP		=> 10;
use constant MONITOR_SYSCALLS		=> 11;
use constant MONITOR_PROCNETDEV		=> 12;
use constant MONITOR_KCACHE		=> 13;
use constant MONITOR_PERFTIMESTAT	=> 14;
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName 	=> "Monitor",
		_DataType	=> 0,
		_FieldHeaders	=> [],
		_FieldLength	=> 0,
		_Headers	=> [ "Base" ],
	};
	bless $self, $class;
	return $self;
}

sub getModuleName() {
	my ($self) = @_;
	return $self->{_ModuleName};
}

sub initialise() {
	my ($self, $reportDir, $testName) = @_;
	my (@fieldHeaders);
	my $fieldLength = 12;

	if ($self->{_DataType} == MONITOR_CPUTIME_SINGLE) {
		$fieldLength = 12;
		@fieldHeaders = ("", "User", "System", "Elapsed");
	}
	$self->{_FieldLength}  = $fieldLength if !defined($self->{_FieldLength});
	$self->{_FieldHeaders} = \@fieldHeaders;
	$self->{_TestName} = $testName;
}

sub setFormat() {
	my ($self, $format) = @_;
	if ($format eq "html") {
		$self->{_PrintHandler} = MMTests::PrintHtml->new();
	} else {
		$self->{_PrintHandler} = MMTests::PrintGeneric->new();
	}
}

sub printReportTop() {
	my ($self) = @_;
	$self->{_PrintHandler}->printTop();
}

sub printReportBottom() {
	my ($self) = @_;
	$self->{_PrintHandler}->printBottom();
}

sub printFieldHeaders() {
	my ($self) = @_;
	$self->{_PrintHandler}->printHeaders(
		$self->{_FieldLength}, $self->{_FieldHeaders},
		$self->{_FieldHeaderFormat});
}

sub printReport() {
	my ($self) = @_;
	if ($self->{_DataType} == MONITOR_CPUTIME_SINGLE ||
	    $self->{_DataType} == MONITOR_PROCVMSTAT ||
	    $self->{_DataType} == MONITOR_LATENCY ||
	    $self->{_DataType} == MONITOR_TOP ||
	    $self->{_DataType} == MONITOR_IOTOP ||
	    $self->{_DataType} == MONITOR_FTRACE ||
	    $self->{_DataType} == MONITOR_IOSTAT ||
	    $self->{_DataType} == MONITOR_PERFTIMESTAT ||
	    $self->{_DataType} == MONITOR_SYSCALLS ||
	    $self->{_DataType} == MONITOR_KCACHE ||
	    $self->{_DataType} == MONITOR_VMSTAT ||
	    $self->{_DataType} == MONITOR_PROCNETDEV) {
		$self->{_PrintHandler}->printRow($self->{_ResultData}, $self->{_FieldLength}, $self->{_FieldFormat});
	} else {
		print "Unknown data type for reporting monitor raw data\n";
	}
}

sub printSummaryHeaders() {
	my ($self) = @_;
	if (defined $self->{_SummaryLength}) {
		$self->{_PrintHandler}->printHeaders(
			$self->{_SummaryLength}, $self->{_SummaryHeaders},
			$self->{_FieldHeaderFormat});
	} else {
		$self->printFieldHeaders();
	}
}

sub printPlot() {
        my ($self, $subheading) = @_;
	$self->printSummary($subheading);
}

sub printSummary() {
	my ($self, $subHeading) = @_;
	my @formatList;
	my $fieldLength = $self->{_FieldLength};
	if (defined $self->{_FieldFormat}) {
		@formatList = @{$self->{_FieldFormat}};
	}

	$self->extractSummary($subHeading);
	$self->{_PrintHandler}->printRow($self->{_SummaryData}, $fieldLength, $self->{_FieldFormat});
}

sub extractSummary() {
	my ($self) = @_;
	$self->{_SummaryData} = $self->{_ResultData};
	$self->{_SummaryHeaders} = $self->{_FieldHeaders};
	return 1;
}

1;
