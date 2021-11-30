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

my $query = "select * from picture where (perl_show = TRUE)";

#query 실행
#my $sth=$dbh->prepare($query);
#$sth->execute();

#while(my $ref = $sth->fetchrow_hashref()){
#	print "Found: $ref->{'perl_tag'}";
#}
#print $sth->rows;

#$execute = $connect->query($query);
#$rownumber = $execute->numrows();
#$fieldnumber = $execute->numfields();

#print $rownumber;
#print $fieldnumber;



my $map = HTML::GoogleMaps::V3->new(
    api_key => "AIzaSyCLBkJIzECZmzeEy_-sdqx6N5WtoiMQWiA",
	height => "900",
	width => "1600"
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
	$gpsLongMod=$ref->{'gpsLongFloat'}+rand()/20000;
	$gpsLatMod=$ref->{'gpsLatFloat'}+rand()/20000;
	$map->add_marker(
		#$ref->{'gpsLongFloat'}
		point => [$gpsLongMod,$gpsLatMod],
		#point => [$ref->{'gpsLongFloat'},$ref->{'gpsLatFloat'}],
		#point => [108.326666667, 15.876111111],
		#html => qq{<img src=$ref->{perl_path} height=$ref->{perl_height}/4, width=$ref->{perl_width}/4>},
		#	);
		#html => qq{<img src=$ref->{perl_path} href=$ref->{perl_path}" >},);
		#html => qq{<a href="$ref->{perl_path}">테스트</a>},);
		html => qq{<a href=$ref->{perl_path}>$ref->{'perl_date'} $ref->{perl_tag}</a>},
		);

		#html => qq{<img src=$ref->{perl_path} >},);
		#		html => qq{<div class="map"><span> 나 여기</span></div>},);
};#while loop

$sth->finish();

my $total=$dbh->prepare("select count(*) as Counter from picture where (perl_show = TRUE)");
#my $total=$dbh->prepare($query);
$total->execute();

#print "여기 확인";
#while(my $ref2 = $total->fetchrow_hashref()){
#	print $ref2->{'Counter'};
#}
#$total->execute();
my $ref2 = $total->fetchrow_hashref();
#print $ref2->{'Counter'};

$total->finish();
$dbh->disconnect();

#print qq{this is..};
#$map->add_marker(
#	point => [108.326666667, 15.876111111],
#	html => qq{<img src="/imageOtherPar/2018/20180504_133649.jpg" height="1024" width="768">},);
#
my ( $head, $map_div ) = $map->onload_render;


#print $head;

#print "여기 학인";
print <<"END_HTML";
<?php /* Template Name: myPhotoWithGps*/ ?>
<?php
get_header(); ?>

<div id="main-content" class="main-content">

<?php
	if ( is_front_page() && twentyfourteen_has_featured_posts() ) {
		// Include the featured content template.
		get_template_part( 'featured-content' );

	}
?>
	<div id="primary" class="content-area">
		<div id="content" class="site-content" role="main">
			<?php
				// Start the Loop.
				while ( have_posts() ) : the_post();

					// Include the page content template.
					get_template_part( 'content', 'page' );


					// If comments are open or we have at least one comment, load up the comment template.
					if ( comments_open() || get_comments_number() ) {
						comments_template();
					}
				endwhile;
			?>

<?php
//로그인 되었는지  확인하는 부분..
if( is_user_logged_in())
{
	echo '환영합니다.';
	?>


<!doctype html>
<html>
<head>
<meta charset="utf-8" />
// markerCluster scipt 위치 표시 .
<script src="../map/marker/src/markerclusterer.js"></script>
END_HTML
#// markers 선언.
#var markers = [];


#print $head . "markers.push(marker)" . "\n";
print $head."\n";

print <<"END_HTML";
</head>
<body onload="html_googlemaps_initialize()">
END_HTML

print $map_div . "\n";

print <<"END_HTML";
</body>
</html>


	<?php
}
else
{
	echo '로그인하지 않고는 볼수 없습니다.';
}
?>



		</div><!-- #content -->

	</div><!-- #primary -->

	<?php get_sidebar( 'content' ); ?>


</div><!-- #main-content -->

<?php
get_sidebar();
get_footer();
END_HTML
