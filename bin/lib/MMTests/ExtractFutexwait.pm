# ExtractFutexwait.pm
package MMTests::ExtractFutexwait;
use MMTests::SummariseMultiops;
use MMTests::Stat;
our @ISA = qw(MMTests::SummariseMultiops);
use strict;
use Data::Dumper qw(Dumper);

sub initialise() {
	my ($self, $reportDir, $testName) = @_;

	$self->{_ModuleName} = "ExtractFutexwait";
	$self->{_DataType}   = DataTypes::DATA_OPS_PER_SECOND;
	$self->{_PlotType}   = "thread-errorlines";
	$self->SUPER::initialise();
}

sub extractReport() {
	my ($self, $reportDir, $reportName, $profile) = @_;
	my ($tp, $name);
	my @threads;

	my @files = <$reportDir/$profile/futexwait-*-1.log>;
	foreach my $file (@files) {
		my @elements = split (/-/, $file);
		my $thr = $elements[-2];
		$thr =~ s/.log//;
		push @threads, $thr;
	}

	foreach my $nthr (@threads) {
		my @files = <$reportDir/$profile/futexwait-$nthr-*.log>;

		foreach my $file (@files) {
			my @split = split /-/, $file;
			$split[-1] =~ s/.log//;
			my $nr_samples = 0;

			open(INPUT, $file) || die("Failed to open $file\n");
			while (<INPUT>) {
				my $line = $_;
				if ($line =~ /Result: ([0-9]+) Kiter\/s/) {
					push @{$self->{_ResultData}}, [ $nthr, ++$nr_samples, $1 ];
				}
			}
			close INPUT;
		}
	}

	my @ops = sort {$a <=> $b} @threads;
	$self->{_Operations} = \@ops;
}
