use utf8;
use strict;
use warnings;
use DBI;
use HTML::GoogleMaps::V3;
#아래내용은 구글MAPs 에 사용.
#binmode STDOUT, ":utf8";

#mysql 설정.
#
#

#my $host ="localhost";
my $host ="127.0.0.1";
my $user = "perlUser";
my $password = "perlUser1!";
my $database = "myHome";
my $tablesname =  "picture";

#모두 붙여서 사용..
#space 있으면 connect 에러
my $dbh = DBI->connect("DBI:mysql:database=$database;host=$host", $user, $password, {RaiseError => 1});


#한글 설정
my $setkorean="SET NAMES utf8";
$dbh->do($setkorean);
#query 설정.
#my $query = "select * from picture where 태그 like '%민수%' limit 10";
#테스트용 query
#my $query = "select * from picture where (gpsLatFloat != 0 and id=34497) limit 10";

my $query = "select * from TRK where year(updated) = 2021 and month(updated) = 11 and day(updated)=27";


my $map = HTML::GoogleMaps::V3->new(
    api_key => "AIzaSyCLBkJIzECZmzeEy_-sdqx6N5WtoiMQWiA",
	height => "800",
	width => "1200"
);


$map->center("경기도 군포시");

#query 실행
my $sth=$dbh->prepare($query);
$sth->execute();

#print (my $refTotal = $total->fetchrow_hashref());
#print $total;
my $gpsLongMod;
my $gpsLatMod;
while(my $ref = $sth->fetchrow_hashref()){
	#print "Found: $ref->{'perl_tag'}";
	#databses에서 입력을 잘못 함. 고칠데 많아서 그냥 씀.
	$gpsLongMod=$ref->{'latitude'};
	$gpsLatMod=$ref->{'longitude'};
	$map->add_marker(
		#$ref->{'gpsLongFloat'}
		point => [$gpsLongMod,$gpsLatMod],
		#point => [$ref->{'gpsLongFloat'},$ref->{'gpsLatFloat'}],
		#point => [108.326666667, 15.876111111],
		#html => qq{<img src=$ref->{perl_path} height=$ref->{perl_height}/4, width=$ref->{perl_width}/4>},
		#	);
		#html => qq{<img src=$ref->{perl_path} href=$ref->{perl_path}" >},);
		#html => qq{<a href="$ref->{perl_path}">테스트</a>},);
		#html => qq{<a href=$ref->{perl_path}>$ref->{'perl_date'} $ref->{perl_tag}</a>},
		);

		#html => qq{<img src=$ref->{perl_path} >},);
		#		html => qq{<div class="map"><span> 나 여기</span></div>},);
};#while loop

$sth->finish();


my ( $head, $map_div ) = $map->onload_render;


print <<"END_HTML";
<div id="main-content" class="main-content">

	<div id="primary" class="content-area">
		<div id="content" class="site-content" role="main">

<!doctype html>
<html>
<head>
<meta charset="utf-8" />
// markerCluster scipt 위치 표시 .
END_HTML
#// markers 선언.
#var markers = [];


print $head."\n";

print <<"END_HTML";
</head>
<body onload="html_googlemaps_initialize()">
END_HTML

print $map_div . "\n";

print <<"END_HTML";
</body>
</html>

END_HTML
