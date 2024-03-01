use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use Data::Dump qw(dump);
#binmode STDERR, ":utf8";ss

my $encoding = 'utf-8';
my $data_directory = "C:\\Users\\meagu\\OneDrive\\Documents\\Proyecto_Limpieza_Datos\\Datos_N\\"; #completa
#my $data_directory = "C:\\Users\\meagu\\OneDrive\\Documents\\Proyecto_Limpieza_Datos\\Prueba\\";#prueba hash_conteo
my $data_directory_out = "C:\\Users\\meagu\\OneDrive\\Documents\\Proyecto_Limpieza_Datos\\ResultadosII\\";
my $override_file_name = "shinano_meiki.txt";#dict0001_co_jp.txt | Dictionary of Intermediate Japanese Grammar.txt
my $batch_size = 1;
my ($line, $count);
my $line_iterator;
my $paragraph_id  = 0;
my $vocabulary_id = 0;
my $jp_filter_regex  = "";
my $discard_regex = "";
                      
my $filtered_str;
my $output_content;
my @txt_file_names_arr = get_directory_or_file_arr($data_directory, "\\.txt|\\.TXT");
my %Hash=();
my $contador=0;
$output_content = "";

############# conteo caracteres 
foreach my $txt_file_name (@txt_file_names_arr) {
  print "\n archivo:","\t" x 3, $txt_file_name, "\n";
  $line_iterator = data_iterator( $data_directory . $txt_file_name, $encoding, $batch_size);
  while ($line = $line_iterator->()){
      chomp  $line;
      my @array = split (//, $line);
      foreach my $letra (@array){
       if (exists $Hash{$letra}) {
        $Hash{$letra}++;
       }else{
        $Hash{$letra}=1;
       }
    }
  }

}
foreach my $key (sort keys %Hash)
{
  $output_content .= $key ."," . $Hash{$key}."\n";
}
my $txt_file_name='elementos.txt';
writeFile($data_directory_out. $txt_file_name, $output_content, $encoding);

############## i_caracteres_propios_japones
$output_content="";
$jp_filter_regex  = "[\\p{Han}\\p{Hiragana}\\p{Katakana}]";
$txt_file_name="i_caracteres_propios_japones.txt";
my %Hash_i=();
foreach my $key ( keys %Hash)
{
      if (($key=~ /$jp_filter_regex/)&&($key =~ /\P{P}/)) {
        $Hash_i{$key}=$Hash{$key};
      }
}
foreach my $key (sort  keys %Hash_i)
{
  $output_content .=$key.",".$Hash_i{$key}.",".sprintf("%X", ord ($key))."\n";
}
writeFile($data_directory_out. $txt_file_name, $output_content, $encoding);

####################### ii - caracteres de puntuación del japonés: comas, guiones, apostrophes, doble "\\x{22}
$output_content="";
$jp_filter_regex  = "[‐、。〃〜〝〟・｡､･]|[・｡､･]|[\\_\\*\\'\\.\\,\\x{22}\\\\;\\:\\!\\-\\+\\\\\\/\\:\\;\\?\\~，·＃＆！．＊＂＇＋～＼％－＿；；？：／…“”―]";
$txt_file_name="ii_caracteres_puntuacion_japones.txt";

my %Hash_ii=();
foreach my $key ( keys %Hash)
{
      if (($key =~ /$jp_filter_regex/)) {
        $Hash_ii{$key}=$Hash{$key};
      }
}
foreach my $key (sort  keys %Hash_ii)
{
  $output_content .=$key.",".$Hash_ii{$key}.",".sprintf("%X", ord ($key))."\n";
}
writeFile($data_directory_out. $txt_file_name, $output_content, $encoding);

####################### iii - caracteres agregados al japonés: brackets, números en variados formatos, etc.c

$output_content="";
$txt_file_name="iii_caracteres_agregados_japones.txt";
my $express="[\\x{3008}-\\x{3019}]|\\x{FF62}|\\x{FF63}|[\\{\\(\\)\\[\\]\\}）［｝＠］｛（]|[\\x{FF10}-\\x{FF19}]|[\\x{30}-\\x{39}]";
my $brakets="[\\{\\}\\(\\)\\[\\]\\x{3008}-\\x{3019}（［｛｢）］｝｣｟｠]";
my $numeros="[\\x{30}-\\x{39}\\x{FF10}-\\x{FF19}\\x{2160}-\\x{2164}\\x{2460}-\\x{2472}\\x{2070}\\x{2074}\\x{2078}\\x{2081}-\\x{2084}\\x{2088}\\x{2776}-\\x{2781}]";

my $mas_caracteres="[\\x{FF21}-\\x{FF3A}\\x{FF41}-\\x{FF5A}λθεζσρφπ×βαγ▸▲◆＠↔→⇒⇔⇨←↑➡×＜＝＞◯※ꜜ°γ•<>｜=\\|]";
my %Hash_iii=();
foreach my $key ( keys %Hash)
{
      if (($key =~ /$brakets|$numeros|$mas_caracteres/) ) {
        $Hash_iii{$key}=$Hash{$key};
      }
}
foreach my $key (sort  keys %Hash_iii)
{
  $output_content .=$key.",".$Hash_iii{$key}.",".sprintf("%X", ord ($key))."\n";
}
writeFile($data_directory_out. $txt_file_name, $output_content, $encoding);
####################### iv - caracteres ajenos al japonés: otros idiomas

$output_content="";
$txt_file_name="iv_caracteres_ajenos_japones.txt";
my %Hash_iV=();
foreach my $key ( keys %Hash)
{
      if (($key !~ /[\p{Han}\p{Hiragana}\p{Katakana}]|$jp_filter_regex|$brakets|$numeros|$mas_caracteres/)) {
        $Hash_iV{$key}=$Hash{$key};
      }
}
foreach my $key (sort  keys %Hash_iV)
{
  $output_content .=$key.",".$Hash_iV{$key}.",".sprintf("%X", ord ($key))."\n";
}
writeFile($data_directory_out. $txt_file_name, $output_content, $encoding);

######uniq   https://perlmaven.com/unique-values-in-an-array-in-perl
###funcion para devolver valores unicos
sub uniq {
  my %seen;
  return grep { !$seen{$_}++ } @_;
}
######https://www.perl.com/pub/2005/06/16/iterators.html/
sub data_iterator{
  my ($file_name, $encoding, $batch_size) = @_;
  my ($index, @batch_indices) = (0, ());
  my $file_content = openFile($file_name, $encoding);
  my @file_content_arr = split "\n", $file_content;
  my $num_samples = @file_content_arr;
  
  return sub {
    $index = 0 if (defined $_[0] && $_[0] == 0);#Reset
    return undef if ($index >= $num_samples);
    my $data_chunk = "";
    $data_chunk .= $file_content_arr[$_] . "\n" for ($index .. $index + $batch_size -1);
    $index += $batch_size;
    return $data_chunk;
  };
}

sub openFile {
    my ($file_name, $codification) = @_;
    $codification = "utf-8" if (!defined $codification || $codification =~ /^\s*$/);
    my $err = 0;
    local $/;
    open (FILE2, "<", $file_name) or $err = 1;
    if ($err == 1) {
        die "Can't read file \"$file_name\" [$!]\n";
    }
    my $fileContent = <FILE2>;
    close FILE2;
    if ($codification eq "utf-8") {
        eval { $fileContent = Encode::decode("utf-8", $fileContent, Encode::FB_CROAK); };
        $fileContent = Encode::decode("utf-16", $fileContent, Encode::FB_CROAK) if ($@);
    }
    elsif ($codification =~ /^\s*$/) { }
    else { $fileContent = Encode::decode($codification, $fileContent, Encode::FB_CROAK); }
    return $fileContent;
}

sub writeFile {
  my($fileName, $content, $encoding, $append) = @_;
  $append = 0 if (!defined $append);
  $encoding = "utf8" if (!defined $encoding);
  my $err = 0;
  open (FILE1, ($append ? ">" : "") . ">:encoding($encoding)", $fileName) or $err = 1;
  if ($err == 1) {
    die "Can't write file \"$fileName\" [$!]\n"
  }
  print FILE1 $content;
  close FILE1;
  return 1;
}

#Retrieves a list of subdirectories or files given an input directory
sub get_directory_or_file_arr{
  my ($input_directory, $reject_regex) = @_;
  
  opendir(DIR, $input_directory) or die $!.$input_directory;
  my @directories_files_arr = ();
  while (my $directory_or_file_name = encode("utf8",readdir(DIR))) {
  next if ($directory_or_file_name !~ m/$reject_regex/);

  push (@directories_files_arr, $directory_or_file_name);
  }
 
  closedir(DIR);
  
  @directories_files_arr  = sort {$a cmp  $b} @directories_files_arr;
  return @directories_files_arr;
}