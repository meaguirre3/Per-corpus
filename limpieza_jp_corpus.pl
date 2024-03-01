use strict;
use warnings;
use Encode qw(decode encode);
use Data::Dump qw(dump);
use utf8;
binmode STDOUT, ":utf8";
#binmode STDERR, ":utf8";

my $encoding = 'utf-8';
my $data_directory = "C:\\Users\\meagu\\OneDrive\\Documents\\Proyecto_Limpieza_Datos\\Prueba\\";
my $override_file_name = "JapanesePod101.com Hiragana [2_3].txt";#dict0001_co_jp.txt | Dictionary of Intermediate Japanese Grammar.txt
my $batch_size = 1;
my ($line, $count);

my $line_iterator;
my $paragraph_id  = 0;
my $vocabulary_id = 0;  #－～~（(「\\[{]
#my $jp_filter_regex  = "([\\p{Han}\\p{Hiragana}\\p{Katakana}]+)";
#my $discard_regex = "(?:\\s|[・ー\\d０１２３４５６７８９。.…,、;!?？：:（）(){}\\[\\]\\/－～~])+";
 
 my $jp_filter_regex  = "";
my $discard_regex = ""; 

my $filtered_str;
my $output_content;
my @txt_file_names_arr = get_directory_or_file_arr($data_directory, "\\.txt|\\.TXT");
print dump(@txt_file_names_arr);
foreach my $txt_file_name (@txt_file_names_arr) {
  #$txt_file_name = $override_file_name if defined $override_file_name;
  Encode::_utf8_on($txt_file_name);
  print "\t" x 3, $txt_file_name, "\n";
 # $txt_file_name="Corso di lingua Giapponese per Italiani - Lezioni 1-15.txt";
  $line_iterator = data_iterator( $data_directory . $txt_file_name, $encoding, $batch_size);
  $output_content = "";
  
  while ($line = $line_iterator->()){
    chomp $line;
    $count = () =  ($line =~ /((?:[βα\!▲↔→⇒⇔…<－―～〜~／'"\*\(\[\{〈《「『【〔〖｟〘（［｛｢\-＃←⇨\x{2460}-\x{2472}＆ꜜ→°※γ•・ー\x{30}-\x{39}\x{FF10}-\x{FF19}\x{2160}-\x{2164}\x{2460}-\x{2472}\x{2070}\x{2074}\x{2078}\x{2081}-\x{2084}\x{2088}\x{2776}-\x{2781}＠=＝\/]*[\p{InHanLeter}\p{InHiraganaLeter}\p{InKatakanaLeter}][π×\)\]\}\-〉》」』】〕〗〙）］｝◯｣。，＋、〜、.…,、；;\!！?？：:％＿／…“”＼\/－～~＜>·｜｠‐_―＆ꜜ→°※γ•・ー\x{30}-\x{39}\x{FF10}-\x{FF19}\x{2160}-\x{2164}\x{2460}-\x{2472}\x{2070}\x{2074}\x{2078}\x{2081}-\x{2084}\x{2088}\x{2776}-\x{2781}＠=＝]*)+\s*(?R)?)/gmu);
    $paragraph_id++ if $count > 1;
    while ($line =~ /((?:[βα\!▲↔→⇒⇔…<－―～〜~／'"\*\(\[\{〈《「『【〔〖｟〘（［｛｢\-＃←⇨\x{2460}-\x{2472}＆ꜜ→°※γ•・ー\x{30}-\x{39}\x{FF10}-\x{FF19}\x{2160}-\x{2164}\x{2460}-\x{2472}\x{2070}\x{2074}\x{2078}\x{2081}-\x{2084}\x{2088}\x{2776}-\x{2781}＠=＝\/]*[\p{InHanLeter}\p{InHiraganaLeter}\p{InKatakanaLeter}][π×\)\]\}\-〉》」』】〕〗〙）］｝◯｣。，＋、〜、.…,、；;\!！?？：:％＿／…“”＼\/－～~＜>·｜｠‐_―＆ꜜ→°※γ•・ー\x{30}-\x{39}\x{FF10}-\x{FF19}\x{2160}-\x{2164}\x{2460}-\x{2472}\x{2070}\x{2074}\x{2078}\x{2081}-\x{2084}\x{2088}\x{2776}-\x{2781}＠=＝]*)+\s*(?R)?)/gmu){
          $filtered_str = $1;
          Encode::_utf8_on($filtered_str);
          print $filtered_str,"\n";
          
          
          
if ($filtered_str =~ /^(?:\\s|\s*[π×▸βα\!▲↔→⇒⇔…<－―～〜~／'"\*\(\[\{〈《「『【〔〖｟〘（［｛｢\-＃←⇨\x{2460}-\x{2472}＆ꜜ→°※γ•ー\x{30}-\x{39}\x{FF10}-\x{FF19}\x{2160}-\x{2164}\x{2460}-\x{2472}\x{2070}\x{2074}\x{2078}\x{2081}-\x{2084}\x{2088}\x{2776}-\x{2781}＠=＝・\)\]\}\-〉》」』】〕〗〙）］｝◯｣。，＋、〜、.…,、；;\!！?？：:％＿／…“”＼\/－～~＜>·｜｠‐_―])+\s*$/){ 
         print 'Eliminado',"\n";
            next; 
         }

         
     
          if ($count > 1){
            $output_content .= "P" . sprintf("%010d", $paragraph_id) . "\t" . $filtered_str . "\n";
          }else{
            $output_content .= "V" . sprintf("%010d", $vocabulary_id++) . "\t" . $filtered_str . "\n";
          }
      }
  }
  my $data_directory_out="C:\\Users\\meagu\\OneDrive\\Documents\\Proyecto_Limpieza_Datos\\Prueba\\";
  $txt_file_name =~ s/(.+?)\.txt/$1_out.txt/;
  writeFile($data_directory_out . $txt_file_name, $output_content, $encoding);
  #last if defined $override_file_name;
}


#####################creacion utf sets
sub InHanLeter{
return <<'END';
+utf8::Han
-utf8::Open_Punctuation
-utf8::Close_Punctuation
END
}
sub InHiraganaLeter{
return <<'END';
+utf8::Hiragana
-utf8::Open_Punctuation
-utf8::Close_Punctuation
END
}
sub InKatakanaLeter{
return <<'END';
+utf8::Katakana
-utf8::Open_Punctuation
-utf8::Close_Punctuation
END
}

#https://www.perl.com/pub/2005/06/16/iterators.html/
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
  while (my $directory_or_file_name =  encode("utf8",readdir(DIR))) {
  next if ($directory_or_file_name !~ m/$reject_regex/);
  push (@directories_files_arr, $directory_or_file_name);
  }
  closedir(DIR);
  @directories_files_arr  = sort {$a cmp  $b} @directories_files_arr;
  return @directories_files_arr;
}