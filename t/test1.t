use Test::More tests=>15;
BEGIN { use_ok('OGDL::Parser') };

my $longstr="Yo, Juan Gallo de Andrada, escribano de C�mara del Rey nuestro se�or, de
los que residen en su Consejo, certifico y doy fe que, habiendo visto por
los se�ores d�l un libro intitulado El ingenioso hidalgo de la Mancha,
compuesto por Miguel de Cervantes Saavedra, tasaron cada pliego del dicho
libro a tres maraved�s y medio; el cual tiene ochenta y tres pliegos, que
al dicho precio monta el dicho libro docientos y noventa maraved�s y medio,
en que se ha de vender en papel; y dieron licencia para que a este precio
se pueda vender, y mandaron que esta tasa se ponga al principio del dicho
libro, y no se pueda vender sin ella. Y, para que dello conste, di la
presente en Valladolid, a veinte d�as del mes de deciembre de mil y
seiscientos y cuatro a�os.

\"Juan Gallo de Andrada\".";

open F, ">test1.g";
print F <<HERE;
list
    1
    	1, 2, 3
    2 1
	2
	3
    3 1, 2, 3
    4 ( 1, 2, 3 )
    5 
  	1
	2
	3
    6 ( 1; 2; 3; )
    
	
list2
    ( level1 1, 2, 3; level2 1, 2, 3; level3 1, 2, 3 )

groups ( a b , c d )
groups ( a , b,  c, d )
groups a ( b, c, d )

tasa \\
  Yo, Juan Gallo de Andrada, escribano de C�mara del Rey nuestro se�or, de
  los que residen en su Consejo, certifico y doy fe que, habiendo visto por
  los se�ores d�l un libro intitulado El ingenioso hidalgo de la Mancha,
  compuesto por Miguel de Cervantes Saavedra, tasaron cada pliego del dicho
  libro a tres maraved�s y medio; el cual tiene ochenta y tres pliegos, que
  al dicho precio monta el dicho libro docientos y noventa maraved�s y medio,
  en que se ha de vender en papel; y dieron licencia para que a este precio
  se pueda vender, y mandaron que esta tasa se ponga al principio del dicho
  libro, y no se pueda vender sin ella. Y, para que dello conste, di la
  presente en Valladolid, a veinte d�as del mes de deciembre de mil y
  seiscientos y cuatro a�os.

  "Juan Gallo de Andrada".

tasa
   "Yo, Juan Gallo de Andrada, escribano de C�mara del Rey nuestro se�or, de
    los que residen en su Consejo, certifico y doy fe que, habiendo visto por
    los se�ores d�l un libro intitulado El ingenioso hidalgo de la Mancha,
    compuesto por Miguel de Cervantes Saavedra, tasaron cada pliego del dicho
    libro a tres maraved�s y medio; el cual tiene ochenta y tres pliegos, que
    al dicho precio monta el dicho libro docientos y noventa maraved�s y medio,
    en que se ha de vender en papel; y dieron licencia para que a este precio
    se pueda vender, y mandaron que esta tasa se ponga al principio del dicho
    libro, y no se pueda vender sin ella. Y, para que dello conste, di la
    presente en Valladolid, a veinte d�as del mes de deciembre de mil y
    seiscientos y cuatro a�os.
  
    \\"Juan Gallo de Andrada\\"."

HERE
close F;
my $g=OGDL::Parser::fileToGraph("test1.g");

ok($g,"File parsing went through");
for (my $i=1; $i<=6; $i++){
    my $s=$g->get("list.$i.[2]");
    ok($s->{"name"} eq '3', "Path $i retrieved correctly");
}

my $s=$g->get("tasa.[0]");
ok($s->{"name"} eq $longstr,"block long string1 test");

$s=$g->get("tasa[1].[0]");
ok($s->{"name"} eq $longstr,"quote long string1 test");

$s=$g->get("groups[].a[2].[1]");
ok($s->{"name"} eq 'c',"group path selection test");


$roundtrip=1;
open F, ">test2.g";
$g->print("printroot"=>0, "singlequote"=>1, "noblockquote"=>1, "filehandle"=>*F);
close F;


$g=OGDL::Parser::fileToGraph("test2.g");

if(!$g){$roundtrip=0;}
else{
    for (my $i=1; $i<=6; $i++){
	$s=$g->get("list.$i.[2]");
	if(!$s){$roundtrip=0;last;}
	if ($s->{"name"} ne '3'){
	    $roundtrip=0;
	    last;
	}
    }
}
$s=$g->get("tasa.[0]");
ok($s->{"name"} eq $longstr,"roundtrip block long string1 test");

$s=$g->get("tasa[1].[0]");
ok($s->{"name"} eq $longstr,"roundtrip quote long string1 test");

$s=$g->get("groups[].a[2].[1]");
ok($s->{"name"} eq 'c',"roundtrip group path selection test");

ok($roundtrip,"Roundtrip test ok");
