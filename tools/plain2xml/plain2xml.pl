#!/usr/bin/perl -Tw
#Parse plain Text and output (pre) SelfLinux XML 
#Rapid Prototyping study [c] Steffen Dettmer <steffen@dett.de> 2003
#For SelfLinux
#
#$Name:  $
#$Revision: 1.3 $
#$Id: plain2xml.pl,v 1.3 2004/01/23 13:14:50 motw Exp $
#$Source: /selflinux/tools/plain2xml/plain2xml.pl,v $

#Dieses Tool liest eine SelfLinux-Plainformat Datei ein und erzeugt XML 
#Code daraus. Siehe unten f�r Hilfe.

#ACHTUNG!
#  Dieses Script mag komplizierter sein, als es aussieht. Bitte
#  vor �nderungen unbedingt perldoc lesen und verstehen!

#Diese Platzhalter werden f�r spitze Klammern verwendet, die in
#  die Ausgabe sollen (also nicht escaped werden sollen):
my $OP = "UNIQUEOPEN";  #"<"
my $CL = "UNIQUECLOSE"; #">"

use strict;
use Getopt::Long;

sub help()
{
    print "Aufruf: $0 [Optionen] --file <plainText>\n";
    print "Optionen:\n";
    print "  --strict    \tStrikte Pr�fungen (Fehler zum Abbruch)\n";
    print "  --strict=i  \tStriktheitsniveau (0: nicht strikt, 5 strikt)\n";
    print "  --verbose   \tAuf�hrlichkeitslevel mittel\n";
    print "  --verbose=i \tAuf�hrlichkeitslevel (0: still, 5 debug)\n";
    print "  --debug     \tDebug-Optionen einstellen\n";
    print "  --help      \tDiese Hilfe und exit\n";
    print "\n";
    print "Beispiel: $0 --strict=1 --verbose=5 --file datei\n";
    print "\n";
    print "Dieses Programm liest einen SelfLinux-Plaintext ein und\n";
    print "versucht, korrektes XML zu erzeugen. Dazu werden �berschriften\n";
    print "an drei Leerzeilen erkannt und die Nummerierungstiefe f�r die\n";
    print "Strukturierung verwendet. Sonderfunktionskommandos k�nnen im\n";
    print "Header oder als erste Zeile in Textbl�cken (Abschnitten) stehen\n";
    print "\n";
    print "Um mehr Hilfe zu erhalten:\n";
    print "perldoc $0 \n";
    print "\n";
    exit (0);
}

# CLI opts
sub getConfig()
{
    my $config = {};

    my $debug = 0;
    my @files = ();
    my $verbose = -1;
    my $strict = -1; #-1 indicates default

    GetOptions ('debug'    => \$debug, 
                'file=s'    => \@files,
                'strict:i'  => \$strict,
                'verbose:i'  => \$verbose,
                'help' => sub { &help; });

    $config->{'debug'} = $debug;
    $config->{'files'} = \@files;

    if ($verbose == -1) {
        #default to zero - currently :-)
        $config->{'verbose'} = 0;
    } elsif ($verbose == 0) {
        #--verbose ohne "=" verwendet:
        $config->{'verbose'} = 2;
    } else {
        #--verbose=level 
        $config->{'verbose'} = $verbose;
    }
    if ($strict == -1) {
        #default to zero - currently :-)
        $config->{'strict'} = 0;
    } elsif ($strict == 0) {
        #--strict ohne "=" verwendet:
        $config->{'strict'} = 5;
    } else {
        $config->{'strict'} = $strict;
    }

    if ($config->{'debug'} > 0) {
        $config->{'verbose'} = 100;
    }

    if ($config->{'verbose'} > 2) {
        use Data::Dumper;
        print Data::Dumper->Dump([$config], ['config']), "\n";
    }

    if ($config->{'verbose'} > 3) {
        print ("files: " . join(",", @{$config->{'files'}}) .  "\n");
    }

    if ($#{$config->{'files'}} < 0) {
        die "Fehler: keine Datei angegeben (--file)!\n";
    }

    return $config;
}

#Liest Datei ein und gibt Referenz auf Liste mit Textzeilen
#  zur�ck
sub getFileContent($$)
{
    my $name = shift;
    my $config = shift;

    print("getFileContent\n") if ($config->{'verbose'} > 2);

    if ($config->{'verbose'} > 2) {
        print ("Lese $name\n");
    }
    open(FILE, $name)
        or die("Fehler beim �ffnen von $name [$!]\n");
        
    my @content = <FILE>;
    close(FILE);
    
    return \@content;
}

#Spezial-Funktion: f�gt zwei Token zur Liste hinzu: einmal ein 
#  blank-Token und das folgende Textblock-Token
sub pushToken($$$$$)
{
    my $tokens = shift; #token list
    my $token = shift;  #the blank-token to push
    my $block = shift;  #reference to lines with block
    my $config = shift;
    my $sourceLine = shift;

    #push blank-token so far (before the block) if there
    #  were some blanks
    if ($token->{'blank'} && $token->{'blank'} > 0) {
        $token->{'type'} = 'blank';
        push(@$tokens, $token);
    }

    #now push the block
    $token = {}; #new token for the block
    $token->{'value'} = $block;
    #for now, the type is of some text
    $token->{'type'} = 'text'; 
    $token->{'sourceLine'} = $sourceLine;
    push(@$tokens, $token);
}

#F�gt eine Warnung zum Token hinzu
sub addWarning($$)
{
    my $token = shift;
    my $warning = shift;
    if (!defined $token->{'type'}) {
        die "interner fehler: token ohne type!\n";
    }
    my $lineInfo = "";
    if ($token->{'sourceLine'}) {
        $lineInfo = " Zeile " . $token->{'sourceLine'};
    }
    warn "Warnung$lineInfo: $warning (type: " . $token->{'type'} .  ")\n";
    push(@{$token->{'warn'}}, $warning);
}

#gets content of lines
#  tokenizes out the blanks
#  returns a reference to an array of tokens
#  tokens are blanks or text blocks
sub tokenize($$)
{
    my $content = shift; #reference to lines
    my $config = shift;

    print ("tokenize\n") if ($config->{'verbose'} > 1);

    my $tokens = []; #list of token references

    #stores lines in a block
    my $block = [];
    my $token = {};

    #push start of text
    {
        $token->{'type'} = 'start';
        $token->{'sourceLine'} = 1;
        push(@$tokens, $token);
        $token = {}; #new token
    }

    $token->{'sourceLine'} = 1;
    for(my $lineNo = 0; $lineNo <= $#$content; $lineNo++) {
        my $line = $content->[$lineNo];
        chomp($line);
        printf "lineNo %6d/%6d: %-50.50s\n", 
                $lineNo, $#$content, $line
            if ($config->{'verbose'} > 3);

        #empty line is special
        if ($line =~ m/^\s*$/) {
            if ($config->{'verbose'} > 3) {
                print Data::Dumper->Dump([$block], ['Block']), "\n";
            }

            print "blank: ", $token->{'blank'} . "\n"
                if ($config->{'verbose'} > 3);
            if ($#$block == -1) {
                #not in a block
            } else {
                pushToken($tokens, $token, $block, $config, $lineNo);
                $block = [];
                $token = {}; #new token
                $token->{'sourceLine'} = $lineNo + 2;
                $token->{'blank'} = 0; #just for readbility
            }
            $token->{'blank'}++;
        } else {
            push(@$block, $line);
        }
    }

    #push unprocessed data
    pushToken($tokens, $token, $block, $config, "(EOF)");
        $token = {}; #new token

    #push end of text
    {
        $token->{'type'} = 'end';
        push(@$tokens, $token);
        $token = {}; #new token
    }

    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$tokens], ['Token']), "\n";
    }

    return $tokens;
}

#Z�hlt Punkte und damit headinglevel in einer �berschrift:
#  1.1.1 Einleitung --> 2
sub countDots($)
{
    my $str = shift;
    my $dots = 0;
    #see man perlop for this tr functionality
    $dots = $str =~ tr/././;
    return $dots;
}

#Analysiert Header
#  im Start-Token werden globale Werte gespeichert.
#  erkennt Autor, Lizenz, Titel, Runlevel
sub analyzeHeader($$$)
{
    my $value = shift; #reference to value array
    my $startToken = shift; #reference list of tokens
    my $config = shift;

    print ("analyzeHeader\n") if ($config->{'verbose'} > 1);

    foreach my $line_v (@$value) {
        my $line = $line_v;
        printf "Headerline: %-50.50s\n", $line
            if ($config->{'verbose'} > 3);
        #ignore "   * " prefix
        $line =~ s/^\s*\*\s*//;
        if ($line =~ m/Autor:\s*(.*)$/i) {
            print("  Autor: $1\n") if ($config->{'verbose'} > 2);
            push(@{$startToken->{'author'}}, $1);
        }
        if ($line =~ m/Layout:\s*(.*)$/i) {
            print("  Layout: $1\n") if ($config->{'verbose'} > 2);
            push(@{$startToken->{'layout'}}, $1);
        }
        if ($line =~ m/Lizenz:\s*(.*)$/i) {
            print("  Lizenz: $1\n") if ($config->{'verbose'} > 2);
            push(@{$startToken->{'license'}}, $1);
        }
        if ($line =~ m/Titel:\s*(.*)$/i) {
            print("  Titel: $1\n") if ($config->{'verbose'} > 2);
            push(@{$startToken->{'title'}}, $1);
        }
        if ($line =~ m/Runlevel:\s*(.*)$/i) {
            print("  Runlevel: $1\n") if ($config->{'verbose'} > 2);
            push(@{$startToken->{'runlevel'}}, $1);
        }
        if ($line =~ m/plain2xml/i) {
            if ($line =~ m/plain2xml\s+command:\s*"(.*)"/i) {
                print("  <command>: $1\n") if ($config->{'verbose'} > 2);
                push(@{$config->{'command'}}, $1);
            } elsif ($line =~ m/plain2xml name:\s*"(.*)"/i) {
                print("  <name>: $1\n") if ($config->{'verbose'} > 2);
                push(@{$config->{'name'}}, $1);
            } else {
                $line =~ m/plain2xml\s*(.*)(\s*-->\s*)\s*$/i;
                my $w = "Fatal: Unbekanntes plain2xml Direktive \"$1\"\n"
                   . "      in Header-Zeile: $line";
                if ($config->{'strict'} >= 1)  {
                    die "strict 1: $w\n";
                } else {
                    addWarning($startToken, $w);
                }
            }
        }

    }
}

#Versucht, Text-Block-Type genauer zu bestimmen
#  Dazu werden Sonderkommandos ausgewertet
sub guessBlockType($$$)
{
    my $token = shift;    #aktuelles Token
    my $pretoken = shift; #Vorg�nger-Token
    my $config = shift;

    #inspizieren der ersten Zeile
    if ($token->{'type'} eq "textblock") {
        if (!$token->{'value'}->[0]) {
            #leerer Block, kann z.B. am Ende stehen
            my $w = "leerer Textblock";
            if ($config->{'strict'} >= 2)  {
                die "strict 2: $w" . $token->{'sourceLine'} . "\n";
            }
            addWarning($token, $w);
            return;
        }
        $token->{'textcontent'} = 1;
        my $line1 = $token->{'value'}->[0];
        if ($line1 =~ m/plain2xml/i) {
            if ($line1 =~ m/plain2xml\s+list\s*:\s+/i) {
                print("  <list>: $1\n") if ($config->{'verbose'} > 2);
                $token->{'type'} = "listblock";
	    } elsif ($line1 =~ m/plain2xml\s+table\s*:\s+([\w=]+)/i) {
                # $1 ist z.B. "columns=3 extraattribute=RFU"
		print("  <table>: $1\n") if ($config->{'verbose'} > 2);
		foreach my $attrib (split(/\s+/, $1)) {
		    my ($key, $value) = split(/\s*=\s*/, $attrib);
		    $token->{'attributes'}->{$key} = $value;
		}
		$token->{'type'} = "tableblock";
	    } else {
		$line1 =~ m/plain2xml\s*(.*)(\s*-->\s*)\s*$/i;
		my $w = "Fatal: Unbekanntes plain2xml Direktive \"$1\"\n"
		  . "      bei: $line1";
		if ($config->{'strict'} >= 1)  {
		    die "strict 1: $w\n";
		} else {
		    addWarning($token, $w);
		}
	    }
            #Steuerzeile kopieren
            $token->{'controlline'} = $line1;
            #remove that first control line
            shift @{$token->{'value'}};
        }
    }
}

#Analysiert Token liste
#  Text und blank sollten alternieren
#  schreibt level der headings rein
#  im Start-Token werden globale Werte gespeichert.
sub analyzeTokens($$)
{
    my $tokens = shift; #reference list of tokens
    my $config = shift;

    print ("analyzeTokens\n") if ($config->{'verbose'} > 1);
    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$tokens], ['Token']), "\n";
    }

    if (!$tokens->[0]->{'type'} eq 'start') {
        die "interner fehler: kein start Token.\n";
    }

    my $headingLevel = 0;
    my $behindHeader = 0;

    #iterate tokens. for the type the predecessor is important
    for(my $tokenNo = 1; $tokenNo < $#$tokens; $tokenNo++) {
        my $token = $tokens->[$tokenNo];
        my $preToken = $tokens->[$tokenNo-1];

        if ($token->{'type'} eq 'text') {
            printf "tokenNo %6d: %-50.50s\n", 
                    $tokenNo,  join(',', @{$token->{'value'}})
                if ($config->{'verbose'} > 3);

            if ($preToken->{'type'} !~ m/^(start|blank|end)$/) {
                die "interner fehler: Text Vorg�nger: " 
                    . $preToken->{'type'} . "\n";
            }
            
            #special: viel whitespace trennt header
            if (    ($preToken->{'type'} eq 'blank')
                 && $preToken->{'blank'} > 3) {
                 addWarning($token, "Mehr als drei Leerzeilen");
                 #push(@{$token->{'warn'}}, 
                 #   "Mehr als drei Leerzeilen");
                 $behindHeader = 1;
            }

            #detect headlines: have tree empty lines before
            if (    ($preToken->{'type'} eq 'blank')
                 && $preToken->{'blank'} == 3) {

                #headline!
                $behindHeader = 1;
                $token->{'type'} = 'heading';
                #Level of Heading fits the numbers
                my $numberStr = "xxx";
                if ($token->{'value'}->[0] =~ m/^\s*([\d.]+)\s+/) {
                    $numberStr = $1;
                } else {
                    #Heading w/o number
                    if ($config->{'strict'} >= 1)  {
                        die "strict 1: �berschrift ohne Nummer: " 
                            .  $token->{'value'}->[0] . "\n";
                    } else {
                        #warn "�berschrift ohne Nummer --> Textblock\n";
                        addWarning($token, 
                            "�berschrift ohne Nummer (zu Textblock)");
                        $token->{'type'} = 'textblock';
                        #push(@{$token->{'warn'}}, 
                        #    "�berschrift ohne Nummer (zu Textblock)");
                    }
                }
                if ($numberStr =~ m/\.$/) {
                    #warn "�berschrift mit Punkt am Ende: $numberStr\n";
                    addWarning($token, 
                        "�berschrift mit Punkt am Ende: \"$numberStr\"");
                    $token->{'type'} = 'textblock';
                    #push(@{$token->{'warn'}}, 
                        #    "�berschrift mit Punkt am Ende: \"$numberStr\"");
                    if ($config->{'strict'} >= 1)  {
                        die "strict 1: �berschrift mit Punkt am Ende: " 
                             . "\"$numberStr\"\n";
                    }
                }
                #"." in $numberStr z�hlen (2.3 ist headingLevel 2)
                #   und $headingLevel anpassen
                $headingLevel = countDots($numberStr) + 1;
                        
            } elsif ($headingLevel == 0) {
                #header (or error :-))
                if ($behindHeader) {
                    $token->{'type'} = 'textblock';
                } else {
                    $token->{'type'} = 'header';
                }
                analyzeHeader($token->{'value'}, $tokens->[0], $config);
                
            } else {
                if (    ($preToken->{'type'} eq 'blank')
                     && ($token->{'value'}->[0])
                     && ($token->{'value'}->[0] =~ m/^\s*\d+/) 
                     && (!defined($token->{'value'}->[1])))
                    {
                    #warn "Einzeliger Textblock mit Ziffer am Anfang\n";
                    addWarning($token,
                        "Einzeliger Textblock mit Ziffer am Anfang");
                    #push(@{$token->{'warn'}},
                    #    "Einzeliger Textblock mit Ziffer am Anfang");
                }
                #assume text block
                $token->{'type'} = 'textblock';
                $behindHeader = 1;
            }
            #guessBlockType($token, $preToken, $config);

            #Token ins level einsortieren
            $token->{'headingLevel'} = $headingLevel;

            printf "tokenNo %6d: type %s\n", 
                    $tokenNo,  $token->{'type'}
                if ($config->{'verbose'} > 3);
        }
    }

    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$tokens], ['Token']), "\n";
    }

}

#forwarder
sub addSubToken($$$$);

#F�gt Token aus Tokens ab position unterhalb node_ref hinzu
#  gibt neue Postition zur�ck
#  F�r das Sortieren werden dabei bis zum n�chsten Heading
#  (�berschrift) eingef�gt. Dabei wird rekursiv gerufen, wenn das
#  Level gr��er ist. Neben der Bedinung "bis zum n�chsten
#  Heading" wird nat�rlich auch bei geringerem Level oder Ende
#  zur�ckgekehrt.
sub addSubToken($$$$)
{
    my $tokens = shift;
    my $config = shift;
    my $node_ref = shift;
    my $position = shift;
    #$node_ref = { 'headingLevel' => 0,
    #              'elements' => [],
    #              'type' => 'node'
    #            };

    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$node_ref], ['addSubTokenNodeRef']), "\n";
    }

    # my level
    if ( ref($node_ref) ne "HASH" ) {
        die "interner fehler: node keine hashref: $node_ref\n";
    }
    if (    (!defined($node_ref->{'headingLevel'}))
         || (!defined($node_ref->{'elements'}))     ) {
        die "interner fehler: node kein headingLevel || elements\n";
    }
    my $level = $node_ref->{'headingLevel'};
    if ($level < 0 || $level > 1000) {
        die "interner fehler: level au�er bereich: $level\n";
    }

    #wir d�rfen nur ein Heading verarbeiten.
    my $hadHeading = 0;

    #iterate einschlie�lich letztem (end token)
    for(my $tokenNo = $position; $tokenNo <= $#$tokens; $tokenNo++) {
        #f�gt elemente an, solange level h�her ist
        my $token = $tokens->[$tokenNo];

        if ($config->{'verbose'} > 3) {
            use Data::Dumper;
            print "*** addSubToken $level at $tokenNo for token:\n";
            print Data::Dumper->Dump([$token], ['token']), "\n";
        }

        #ende der liste
        if ($tokenNo == $#$tokens) {
            if ($token->{'type'} ne 'end') {
                die "interner fehler: kein end am Ende.\n";
            }
            #zur�ck zum root level:
            if ($level > 0) {
                #-1: das token ist noch nicht verarbeitet
                return ($tokenNo - 1);
            }
            #root level pusht den mal noch
            push @{$node_ref->{'elements'}}, $token;
            #raus hier
            return ($tokenNo);
        }

        if ($token->{'isHeader'}) {
            print "skipping headertoken\n"
                if ($config->{'verbose'} > 2);
            #next;
        } elsif (!defined($token->{'headingLevel'})) {
            #blank?
            if ($token->{'type'} ne 'blank') {
                die "interner fehler: no level, no blank\n";
            }
            push @{$node_ref->{'elements'}}, $token;
        
        } elsif ($token->{'headingLevel'} > $level) {
            #wenn level gr��er, dann sub node machen
            my $sub_node = { 'headingLevel' => $level + 1,
                             'elements' => [],
                             'type' => 'node'
                           };
            print Data::Dumper->Dump([$sub_node], ['new sub_node']), "\n"
                if ($config->{'verbose'} > 3);;
            #in die Struktur klinken
            push @{$node_ref->{'elements'}}, $sub_node;
            #und ausf�llen
            print "Recursion level from $level prepare at $tokenNo\n"
                if ($config->{'verbose'} > 2);
            #(Das aktuelle Token dabei nochmal verarbeiten)
            $tokenNo = addSubToken($tokens, $config, $sub_node, $tokenNo);
            print "Recursion level $level back at $tokenNo\n"
                if ($config->{'verbose'} > 2);

        } elsif ($token->{'type'} eq 'heading') {
            #Ein Subnode (also ne section sp�ter) enth�lt ne
            #  �berschrift und dann textbl�cke bis zur n�chsten
            #  �berschrift. Diese n�chste ist eine eigene
            #  Section. Also hier bei der 2. returnen ohne zu
            #  behandeln. Wir werden sofort mit neuem Node
            #  aufgerufen und haben dann wieder 1. heading
            if ($hadHeading > 0) {
                #2. �berschrift in "gleicher Ebene" macht unser Aufrufer
                #-1: das token ist noch nicht verarbeitet
                print "Recursion level $level done at $tokenNo"
                      . " by heading\n"
                      if ($config->{'verbose'} > 2);
                return ($tokenNo - 1);
            } 
            $hadHeading++;
            push @{$node_ref->{'elements'}}, $token;
        } elsif ($token->{'headingLevel'} == $level) {
            #wenn level pa�t, direkt rein (ist vermutlich
            #  textblock oder was verwandtes
            push @{$node_ref->{'elements'}}, $token;
        } else {
            #wenn level kleiner, sind wir fertig.
            print "Recursion level $level done at $tokenNo\n"
                if ($config->{'verbose'} > 2);
            return $tokenNo;
        }
    }
    #Ende der liste? Kein End token? unerreichbar hier!
    die "interner fehler: listen ende verpa�t\n";
}

#Strukturiert Token liste
#  verwendet headingLevel, um hierachische Struktur zu erzeugen.
#  im Start-Token werden globale Werte gespeichert.
sub structureTokens($$)
{
    my $tokens = shift; #reference list of tokens
    my $config = shift;

    print ("structureTokens\n") if ($config->{'verbose'} > 1);
    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$tokens], ['Token']), "\n";
    }

    if (!$tokens->[0]->{'type'} eq 'start') {
        die "interner fehler: kein start Token.\n";
    }

    my $headingLevel = 0;
    my $lastLevel  = 0;

    #Struktur erzeugen. Root-Node hat start.
    my $rootNode = { 'headingLevel' => 0,
                     'elements' => [],
                     'type' => 'node',
                     'start' => $tokens->[0],
                     'header' => []
                   };
    #root-Node in Struktur packen
    my $structure = [ $rootNode ];

    #der root node ist das erste, unter dem h�ngt dann der Rest.
    my $node_ref = $structure->[0];

    #letzen Header token finden
    my $lastHeaderTokenIndex = $#$tokens;
    for(my $tokenNo = $#$tokens; $tokenNo > 0; $tokenNo--) {
        if ($tokens->[$tokenNo]->{'type'} eq 'header') {
            $lastHeaderTokenIndex = $tokenNo;
            last;
        }
    }

    #Header token an root node anh�ngen
    for(my $tokenNo = 1; $tokenNo <= $lastHeaderTokenIndex; $tokenNo++) {
        #f�gt elemente an, solange level h�her ist
        my $token = $tokens->[$tokenNo];

        if (    ($token->{'type'} eq 'header')
             || ($token->{'type'} eq 'blank')  ) {
            #markieren, damit blanks nicht nochmal behandelt werden
            $token->{'isHeader'} = 1;
            push @{$node_ref->{'header'}}, $token;
        } else {
            if ($config->{'verbose'} > 3) {
                use Data::Dumper;
                print Data::Dumper->Dump([$token], ['headerToken']), "\n";
            }
            die "interner fehler: header ohne header (blank)\n";
        }
    }

    #f�gt elemente an, solange level h�her ist. 
    #  Der einfachheit halber werden $tokens und ein Index
    #  �bergeben.
    addSubToken($tokens, $config, $node_ref, 1);

    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$structure], ['structure']), "\n";
    }

    return $structure;
}

#forwarder
sub processNode($$$);

#�berarbeitet ein Node (rekursiv)
#  Hier werden Blocktypen erkannt und URLs markiert. Hier wird
#  guessBlockType aufgerufen.
sub processNode($$$)
{
    my $parent = shift;
    my $node = shift;
    my $config = shift;


    print "processNode\n"
        if ($config->{'verbose'} > 2);
    
    if ($config->{'verbose'} > 3) {
        use Data::Dumper;
        print Data::Dumper->Dump([$node], ['processNode']), "\n";
    }

    #foreach my $key (keys %{$node}) {
    #    print "$key -> " . $node->{$key} . "\n";
    #}

    foreach my $token (@{$node->{'elements'}}) {

        guessBlockType($token, $parent, $config);

        print "bearbeite elementToken type: " . $token->{'type'} . "\n"
            if ($config->{'verbose'} > 2);

        if ($token->{'type'} eq 'node') {
            processNode($node, $token, $config);
        } elsif ($token->{'textcontent'}) {
            my $new = [];
            foreach my $line (@{$token->{'value'}}) {
                $line =~ s{\b((http|ftp):[\w/#~:?+=&%@!\-.:?\-]+?)(?=[.:?\-]*[^\w/#~:?+=&%@!\-.:?\-]|$)}
#                $line =~ s{((http|ftp)://\S+)}
                          {${OP}ref url="$1"${CL}$1${OP}/ref${CL}};
                push @{$new}, $line;

            }
            $token->{'value'} = $new;
        }
    }
}

#Struktur �berarbeiten
sub processStructure($$)
{
    my $structure = shift;
    my $config = shift;

    processNode($structure->[0]->{'start'}, $structure->[0], $config);
}

sub indentStr($)
{
    my $level = shift;
    return ( " " x ($level * 2) );
}

#gewinnt Name und Email
sub parseNameEmail($$)
{
    my $author_str = shift;
    my $config = shift;

    if ($author_str =~ m/^(.*)\s+<?([\S]+@[\w.]+)?>?$/) {
        my $name = $1;
        if (!defined($2) && $config->{'strict'} >= 1) {
            die "parseNameEmail: E-Mail Erkennung fehlgeschlagen:"
            . "\"$author_str\"\n";
        }
        my $email = $2 || 'info@selflinux.de';

        return ($name, $email);
    } else {
        return ("", "");
    }
}

#"Name" ist hier sowas wie layout oder autor mit mailto.
sub writeXMLName($$$)
{
    my $what = shift;
    my $startToken = shift;
    my $config = shift;

    if (    ($what ne "author")
         && ($what ne "layout") ) {
         die "interner fehler: writeXMLName($what)\n";
    }

    my $tagblock = "";

    foreach my $name_str (@{$startToken->{$what}}) {
        my ($name, $email) = parseNameEmail($name_str, $config);
        if ($name ne "") {
            $tagblock .= " <$what>\n";
            $tagblock .= "  <name>" . $name . '</name>' . "\n";
            $tagblock .= "  <mailto>" . $email . '</mailto>' . "\n";
            $tagblock .= " </$what>\n\n";
        } else {
            my $w = "Namensformat/email nicht erkannt: $name_str ($what)";
            addWarning($startToken, $w);
            $tagblock .= writeXMLWarning("\n", $startToken);
            if ($config->{'strict'} >= 2) {
                die "strict 2: Namensformat nicht erkannt\n";
            }
        }
    }
   
    return $tagblock;
}

#this function isn't nice...
#Erzeugt <chapter> mit "XML Header".
#  Das ist alles hardcoded, weil es noch keine Gute Template-Idee
#  gibt.
sub makeChapterStart($$)
{
    my $startToken = shift;
    my $config = shift;
    my $header = "";
    
    my $runlevel = "user";
    if ($startToken->{'runlevel'}) {
       $runlevel = join (", ", @{$startToken->{'runlevel'}});
    }
    $header .= '<chapter runlevel="' . $runlevel . '">' . "\n";

    $header .= ' <cvs>' . "\n";
    $header .= '  <name>$Name'
                    . '$</name>' . "\n";
    $header .= '  <id>$Id' 
                    . '$</id>' . "\n";
    $header .= '  <revision>$Revision'
                    . '$</revision>' . "\n";
    $header .= '  <source>$Source'
                    . '$</source>' . "\n";
    $header .= ' </cvs>' . "\n\n";

    foreach my $title (@{$startToken->{'title'}}) {
        $header .= ' <title>' . $title . '</title>' . "\n\n";
    }

    $header .= writeXMLName("author", $startToken, $config);
    $header .= writeXMLName("layout", $startToken, $config);

    foreach my $license (@{$startToken->{'license'}}) {
        $header .= ' <license>' . "\n";
        $header .= '    ' . $license . "\n";
        $header .= ' </license>' . "\n\n";
    }

    my $filename = $startToken->{'filename'};
    $filename =~ tr |A-Za-z0-9|_|c;
    $header .= ' <index>' . $filename .  '</index>'  . "\n\n";

    return $header;
}

sub makeChapterEnd($)
{
    my $startToken = shift;
    my $footer = "";

    $footer .= "</chapter>\n";

    return $footer;
}

#\deprecated see \ref writeXML
#Schreibt analysierte Token als XML
#  das ist auch nur ein Hack. Vielleicht lieber die Tokenliste
#  in einen Baum umbauen. Aber ein Programm, was gar nix ausgibt,
#  ist ja ganz doof - sieht man ja nix...

#INAKTIV
#XXX TODO Remove me
sub writeXML_old($$)
{
    my $tokens = shift; #reference list of tokens
    my $config = shift;

    print ("writeXML\n") if ($config->{'verbose'} > 2);

    if (!$tokens->[0]->{'type'} eq 'start') {
        die "interner fehler: kein start Token.\n";
    }

    my $file = $tokens->[0]->{'filename'};
    open(XML, ">" . $file . ".preXML_old_output_algo")
        or die ("Kann $file nicht erzeugen [$!]\n");


    my $indentLevel = 0;
    my $lastLevel  = 0;
    my $headHack = 1; #write a header somewhen
TOKEN:
    for(my $tokenNo = 1; $tokenNo < $#$tokens; $tokenNo++) {
        my $token = $tokens->[$tokenNo];
        if ($token->{'type'} eq 'blank') {
            next TOKEN;
        } elsif ($token->{'type'} eq 'header') {
            print XML join("\n", @{$token->{'value'}}), "\n";
        } elsif ($token->{'type'} eq 'heading') {
            if ($headHack == 1) {
                print XML makeChapterStart($tokens->[0], $config);
                $lastLevel++;
                $indentLevel++;
                $headHack = 0;
            }
            while ($lastLevel < $token->{'headingLevel'}) {
                print XML indentStr($indentLevel) . "<section>\n";
                $lastLevel++;
                $indentLevel++;
            }
            while ($lastLevel > $token->{'headingLevel'}) {
                $indentLevel--;
                print XML indentStr($indentLevel) . "</section>\n\n";
                $lastLevel--;
            }
                print XML indentStr($indentLevel) . "<section>\n";
                $lastLevel++;
                $indentLevel++;
            print XML indentStr($indentLevel) . "<heading>\n";
            print XML join(" ", @{$token->{'value'}}) . "\n";
            print XML indentStr($indentLevel) . "</heading>\n\n";
        } elsif ($token->{'type'} eq 'textblock') {
            print XML indentStr($indentLevel) . "<textblock>\n";
            print XML join("\n", @{$token->{'value'}}) . "\n";
            print XML indentStr($indentLevel) . "</textblock>\n\n";
        }
    }
    while ($lastLevel>0) {
        $indentLevel--;
        print XML indentStr($indentLevel) . "</section>\n\n";
        $lastLevel--;
    }

    close (XML);
}

#Macht aus header element des root nodes (ist ne liste von token) 
#  den Header als XML Kommentar.
sub makeHeader($$)
{
    my $tokens = shift;
    my $config = shift;
    
    my $block = "";
    foreach my $token (@$tokens) {

        if ($config->{'verbose'} > 3) {
            use Data::Dumper;
            print Data::Dumper->Dump([$token], ['makeHeaderToken']), "\n";
        }

        if (!defined($token->{'isHeader'})) {
            die "interner fehler: makeHeader erfordert isHeader token\n";
        }
        if ($token->{'type'} eq 'blank') {
            $block .= "\n" x $token->{'blank'};
        } elsif ($token->{'type'} eq 'header') {
            $block .= join("\n", @{$token->{'value'}}) . "\n";
        } else {
            die "interner fehler: falscher header token type" 
                .  $token->{'type'} . "\n";
        }
    }

    #eventuellen "<!--" HTML kommentare entfernen
    $block =~ s|<!--||g;
    $block =~ s|-->||g;
        
    return ( "<!--", $block, "-->\n" );
}

#schneitet nummer vorn vom String ab
sub writeXMLHeadingValue($$$)
{
    my $joiner = shift;
    my $token = shift;
    my $config = shift;

    if (!$token->{'type'} eq "heading") {
        die "interner fehler: writeXMLHeadingValue for not header: "
         . $token->{'type'} . "\n";
    }
    if ($token->{'headingLevel'} <= 0) {
        die "interner fehler: writeXMLHeadingValue for level <= 0: "
         . $token->{'headingLevel'} . "\n";
    }
    $token->{'value'}->[0] =~ s/^\s*[\d.]+\s*//;
    writeXMLValue($joiner, $token, $config);
}

#formatiert Warnung eines Tokens in einen Kommentar.
sub writeXMLWarning($$)
{
    my $joiner = shift;
    my $token = shift;

    my $warning = "";
    if (defined($token->{'warn'})) {
        $warning = "<!-- $0: WARNUNG Zeile "
            . $token->{'sourceLine'} . ":"
            . "$joiner     "
            . join("$joiner     ", @{$token->{'warn'}})
            . " -->\n";
    }

    return $warning;
}

#schreibt node->value als list. EXPERIMENTAL.
sub writeXMLList($$$)
{
    my $joiner = shift;
    my $token = shift;
    my $config = shift;

    my $block;

    $block .= $token->{'controlline'} || "";
    $block .= $joiner;
    
    my $indent = $token->{'headingLevel'} * 1 + 2;
    $indent = " " x $indent;

    $block .= $indent . "<ul>\n";

    my $newToken = { 'type' => 'textblock',
                     'value' => [] 
                   };
    #XXX TODO Das ist zu einfach, weil sp�ter ja ein List-Element �ber
    #  mehrere Zeilen gehen darf
    foreach my $line (@{$token->{'value'}}) {
        $line =~ s|^\s*-\s+(.*)$|${indent} ${OP}li${CL}$1${OP}/li${CL}|;
        push @{$newToken->{'value'}}, $line;
    }
    $block .= writeXMLValue("\n", $newToken, $config). "\n";
    $block .= $indent . "</ul>";

    return $block;
}

#schreibt node->value als Tabelle. EXPERIMENTAL.
sub writeXMLTable($$$)
  {
    my $joiner = shift;
    my $token = shift;
    my $config = shift;

    my $block;

    $block .= $token->{'controlline'} || "";
    $block .= $joiner;

    my $indent = $token->{'headingLevel'} * 1 + 2;
    $indent = " " x $indent;

    $block .= $indent . "<table>\n";

    my $cols = $token->{'attributes'}->{'columns'} || 0;
    for (my $c = 0; $c < $cols; $c++){
	$block .= $indent . " <pdf-colum/>\n"
    }
    my $newToken = { 'type' => 'textblock',
                     'value' => [] 
                   };
    #XXX TODO Das ist zu einfach, weil sp�ter ja ein List-Element �ber
    #  mehrere Zeilen gehen darf
    foreach my $line (@{$token->{'value'}}) {
        chomp $line;
        push @{$newToken->{'value'}}, $indent . " ${OP}tr${CL}\n"
                                    . $indent . "  ${OP}td${CL}";

        my @record = split(/\|/, $line);
        foreach my $f (@record) {
            $f =~ s/^\s+//;
            $f =~ s/\s+$//;
        }
        #squash blanks
        map { s/(^\s+|\s+$)// } @record;
        push @{$newToken->{'value'}}, join(     "\n"
                                    . $indent . "  ${OP}/td${CL}\n"
                                    . $indent . "  ${OP}td${CL}\n",
                                      @record);

        push @{$newToken->{'value'}}, $indent . "  ${OP}/td${CL}\n"
                                    . $indent . " ${OP}/tr${CL}";
    }
    $block .= writeXMLValue("\n", $newToken, $config). "\n";
    $block .= $indent . "</table>";

    return $block;
}

#schreibt node->value, z.B. textblock-Inhalt oder �berschrift
#  dabei werden XML Sonderzeichen in Entities konvertiert.
#  Das kann so nicht bleiben, wenn man XML Werte ins plain
#  schreiben m�chten darf.
sub writeXMLValue($$$)
{
    my $joiner = shift;
    my $token = shift;
    my $config = shift;

    my $warning = writeXMLWarning($joiner, $token);

    my $output = join($joiner, @{$token->{'value'}});

    #syntactically required:
    {
        #das zeichen erzeugen wir selbst. M�ssen also als erstes
        #  �bersetzen
        $output =~ s/&/&amp;/g;
        
        #das folgende geht schief f�r "<<", mu� man zweimal ran
        $output =~ s/<([^!])/&lt;$1/g;
        $output =~ s/<([^!])/&lt;$1/g;

        #das geht schief f�r >>>, mu� man dreimal ran.
        $output =~ s/([^-][^-])>/$1&gt;/g;
        $output =~ s/([^-][^-])>/$1&gt;/g;
        $output =~ s/([^-][^-])>/$1&gt;/g;
    }

    #Nun die "command" aus $confgi anwenden
    foreach my $command (@{$config->{'command'}}) {
        $output =~ s|\b($command)\b|<command>$1</command>|g;
    }
    #dito f�r "name"
    foreach my $command (@{$config->{'name'}}) {
        $output =~ s|\b($command)\b|<name>$1</name>|g;
    }

    #eigene <>-Marker zur�cksetzen
    $output =~ s/${OP}/</g;
    $output =~ s/${CL}/>/g;
    
    return $warning . $output;
}

#Schreibt root node
#  der hat den Header (der wurde schon geschrieben)
#  der hat dann <chapter> und <description>
#  das meiste wird dann an writeXMLnode delegiert.
sub writeXMLRootNode($$)
{
    my $node_ref = shift;
    my $config = shift;

    #an einem Node interessieren uns die Elements, die wir
    #  als section schreiben. Einige Elemente
    #  kommen nat�rlich in Tags.
    #Das RootNode ist als einziges keine Section, sondern
    #  ein chapter mit evtl. descriptions. Hier also
    #  Sonderbehandlung.

    #indent level berechnen:
    my $indent = $node_ref->{'headingLevel'} * 1;
    $indent = " " x $indent;
    
    my $block = "";
    $block .= $indent . "<!-- $0: Beginn des Wurzel-Nodes Level " 
                    .  $node_ref->{'headingLevel'} . " -->\n";

    $block .= $indent . "<!-- $0: Beginn des Chapter Starts -->\n";
    $block .= makeChapterStart($node_ref->{'start'}, $config);
    $block .= "<!-- $0: Ende des Chapter Starts -->\n";

    #alle elemente durchgehen
    foreach my $token (@{$node_ref->{'elements'}}) {
        if ($config->{'verbose'} > 3 && $token->{'type'} ne 'node') {
            use Data::Dumper;
            print Data::Dumper->Dump([$token], ['rootToken']), "\n";
        }
        print "schreibe rootToken type: " . $token->{'type'} . "\n"
            if ($config->{'verbose'} > 2);

        if ($token->{'type'} eq 'node') {
            #rekursion ins n�chste Level
            $block .= $indent . " <split>\n";
            $block .= writeXMLnode($token, $config);
            $block .= $indent . " </split>\n\n";
        } elsif ($token->{'type'} eq 'blank') {
            #Leerzeilen
            #ersters sieht doof aus, ist aber richtiger.
            #$block .= "\n" x $token->{'blank'};
            $block .= "\n";
        } elsif ($token->{'type'} eq 'heading') {
            #parse Fehler! Heading ohne Heading-Erkennung?
            #  m��te in einem sub node stehen
            die "strict 2: interner Fehler: Heading ohne Heading-Kennung (l0)\n"
                if ($config->{'strict'} >= 2);
            $block .= $indent . "<!-- Heading ohne Heading-Kennung (l0) -->";
            $block .= $indent . "<!-- [heading] -->";
            $block .= writeXMLValue(" ", $token, $config);
            $block .= "<!-- [/heading] -->\n\n";
        } elsif ($token->{'type'} eq 'textblock') {
            #top level textblock ist description
            $block .= $indent . " <description>\n";
            $block .= writeXMLValue("\n", $token, $config) . "\n";
            $block .= $indent . " </description>\n\n";
        } elsif ($token->{'type'} eq 'end') {
            #do nothing now :-)
        } else {
            die "interner fehler: writeXMLRootNode mit type "
                . $token->{'type'} . "\n";
        }
    }

    $block .= $indent . "<!-- $0: Beginn des Chapter Endes -->\n";
    $block .= $indent . makeChapterEnd($node_ref);
    $block .= $indent . "<!-- $0: Ende des Chapter Endes -->\n";

    $block .= $indent . "<!-- $0: Ende des Wurzel-Nodes Level "
                    .  $node_ref->{'headingLevel'} . " -->\n";

    return $block;
}

#forwarder
sub writeXMLnode($$);

#Schreibt einen XML node
#  der hat dann <section> und <textblock>
#  sub-nodes werden durch rekusrsiven Aufruf geschrieben
sub writeXMLnode($$)
{
    my $node_ref = shift;
    my $config = shift;

    #an einem Node interessieren uns die Elements, die wir
    #  als section schreiben. Einige Elemente
    #  kommen nat�rlich in Tags.

    #indent level berechnen:
    my $indent = $node_ref->{'headingLevel'} * 1 + 1;
    $indent = " " x $indent;
    my $indent2 = $indent . " ";
    
    my $block = "";
    $block .= $indent . "<!-- $0: Beginn eines Nodes Level " 
                    .  $node_ref->{'headingLevel'} . " -->\n";
    $block .= $indent . "<section>\n";

    foreach my $token (@{$node_ref->{'elements'}}) {
        if ($config->{'verbose'} > 3 && $token->{'type'} ne 'node') {
            use Data::Dumper;
            print Data::Dumper->Dump([$token], ['elementToken']), "\n";
        }
        print "schreibe elementToken type: " . $token->{'type'} . "\n"
            if ($config->{'verbose'} > 2);

        if ($token->{'type'} eq 'node') {
            $block .= writeXMLnode($token, $config);
        } elsif ($token->{'type'} eq 'blank') {
            #ersters sieht doof aus, ist aber richtiger.
            #$block .= "\n" x $token->{'blank'};
            $block .= "\n";
        } elsif ($token->{'type'} eq 'heading') {
            $block .= $indent2 . "<heading>\n";
            #$block .= join(" ", @{$token->{'value'}});
            $block .= writeXMLHeadingValue(" ", $token, $config) . "\n";
            $block .= $indent2 .  "</heading>\n";
        } elsif ($token->{'type'} eq 'textblock') {
            $block .= $indent2 . "<textblock>\n";
            #$block .= join("\n", @{$token->{'value'}}) . "\n";
            $block .= writeXMLValue("\n", $token, $config). "\n";
            $block .= $indent2 . "</textblock>\n";
        } elsif ($token->{'type'} eq 'listblock') {
            #$block .= $indent2 . "<textblock>\n";
            $block .= writeXMLList("\n", $token, $config). "\n";
            #$block .= $indent2 . "</textblock>\n";
        } elsif ($token->{'type'} eq 'tableblock') {
            #$block .= $indent2 . "<textblock>\n";
            $block .= writeXMLTable("\n", $token, $config). "\n";
            #$block .= $indent2 . "</textblock>\n";
        } elsif ($token->{'type'} eq 'end') {
            #do nothing now :-)
        } else {
            die "interner fehler: writeXMLnode mit type "
                . $token->{'type'} . "\n";
        }
    }

    $block .= $indent . "</section>\n";
    $block .= $indent . "<!-- $0: Ende eines Nodes Level "
                    .  $node_ref->{'headingLevel'} . " -->\n";

    return $block;
}
    

#Schreibt analysierte Struktur als XML
sub writeXML($$)
{
    my $structure = shift; #reference list of tokens
    my $config = shift;

    print ("writeXML\n") if ($config->{'verbose'} > 2);


    #erste mu� start token sein
    if (!$structure->[0]->{'type'} eq 'node') {
        die "interner fehler: kein node element.\n";
    }

    if (!defined($structure->[0]->{'start'})) {
        die "interner fehler: kein start am node.\n";
    }
    if (defined($structure->[1])) {
        die "interner fehler: Struktur mit zwei wurzeln?\n";
    }

    my $startToken = $structure->[0]->{'start'};

    my $file = $startToken->{'filename'};
    open(XML, ">" . $file . ".preXML")
        or die ("Kann ${file}.preXML nicht erzeugen [$!]\n");


    #sollte auch nach writeXMLRootNode.
    print XML '<?xml version="1.0" encoding="ISO-8859-1"?>' .  "\n";
    print XML "<!-- $0: Beginn des Headers -->\n";
    print XML makeHeader($structure->[0]->{'header'}, $config);
    print XML "<!-- $0: Ende des Headers -->\n";

    #print XML "<!-- $0: Beginn des Chapter Starts -->\n";
    #print XML makeChapterStart($startToken);
    #print XML "<!-- $0: Ende des Chapter Starts -->\n";

    #start recursion
    print XML writeXMLRootNode($structure->[0], $config);

    close (XML);
}

sub processFile($$$)
{
    my $content = shift; #reference to lines
    my $filename = shift; 
    my $config = shift;

    print ("processFile: $filename\n") if ($config->{'verbose'} > 0);

    my $level = 1;
    
    my $tokens = tokenize($content, $config);

    if (!$tokens->[0]->{'type'} eq 'start') {
        die "interner fehler: kein start Token.\n";
    }
    $tokens->[0]->{'filename'} = $filename;

    print "*" x 70, "\n* Analysiere Token\n", "*" x 70, "\n"
        if ($config->{'verbose'} > 1);
    analyzeTokens($tokens, $config);

    print "*" x 70, "\n* Strukturiere Token\n", "*" x 70, "\n"
        if ($config->{'verbose'} > 1);
    my $structure = structureTokens($tokens, $config);

    processStructure($structure, $config);

    writeXML($structure, $config);

    #writeXML_old($tokens, $config);
    

}

sub mainFunc {
    my $config = getConfig();
    #loop only 0 for now :-)
    my $fileName = $config->{'files'}[0];

    #verify and untaint:
    $fileName =~ tr|a-zA-Z0-9_-||cd;
    $fileName =~ m/^(.*)$/g;
    $fileName = $1;

    my $contents = getFileContent($fileName, $config);
    processFile($contents, $fileName, $config);
}

mainFunc();

__END__;

=head1 NAME

plain2xml.pl - SelfLinux plain-Text nach XML Konvertierer

=head1 SYNTAX

B<./plain2xml.pl> [B<--strict>=i] [B<--verbose>=i]
[B<--debug>] [B<--help>] B<--file> dokument

=over 2

=item --strict    

Strikte Pr�fungen (alle  Fehler f�hren zum Abbruch)

=item --strict=i  

Striktheitsniveau ausw�hlen. i ist Wert zwischen 0 und 5. Bei
0 sind keine strikten Pr�fungen oder Abbr�che aktiviert, bei 5
alle.

=item --verbose   

Mittelren Auf�hrlichkeitslevel einstellen.

=item --verbose=i 

Auf�hrlichkeitslevel genau einstellen. i ist Wert zwischen 0
(still) und 5 (debug).

=item --debug     

Debug-Optionen einstellen. Erzeugt gaaanz viel Ausgabe. 

=item --help      

Kurze Benutzungshilfe anzeigen.

=back

=head1 BESCHREIBUNG

Dieses Tool liest eine SelfLinux-Plainformat Datei ein. Als
Ausgabe wird daraus eine XML Datei im SelfLinux-Format erzeugt.
Diese dient als Vorlage f�r die layoutete XML Version dieser
Datei. Es wird also ein XML-Vorformat erzeugt, um Schreibarbeit
zu sparen. Der Dateiname der Ausgabedatei hat die Erweiterung
B<preXML>.

Leerzeilen sind Trenner zwischen Bl�cken (bzw. Abs�tzen)
verschiedenen Types. Das wichtigste Strukturierungsmerkmal sind
�berschriften, die verschiedene Gliederungstiefen anzeigen.

Vor einer �berschrift stehen genau (!) drei Leerzeilen. Eine
�berschrift hat eine Nummern vorn. Mehrstellige sind durch Punkte
getrennt. Die Nummer selbst ist unerheblich. Beispiel (aus
Formatierungsgr�nden steht hier f�lschlicherweise nur je eine
anstatt drei Leerzeilen): 

=over 4

=item 

1 Eins

1.1 Eins-Eins

1.1 Eins-Zwo

1 Zwo

=back

Anhand der �berschriften kann so die Gliederung bestimmt und �ber
B<E<lt>sectionE<gt>>s ausgedr�ckt werden.

=head2 Eingabeformat

Die Eingabedatei mu� den Autorenrichtlinien gen�gen. B<plain2xml>
wertet etliche Merkmale aus; enth�lt der Text
Formatierungsfehler, so wird das erzeugte XML Dokument den
Erwartungen nicht gerecht, so da� der Text eine QA1 Freigabe
haben sollte.

Die Eingabedatei besteht zun�chst aus Abschnitten, die durch
eine Leerzeile getrennt sind. Diese werden hier als Textbl�cke
bezeichnet. Es gibt �berschriften, die durch
drei voranstehende Leerzeilen markiert sind.

Zeilen bis zur ersten �berschrift gelten als "Header". Dieser
wird als XML Kommentar in die Ausgabe �bernommen. Ein Header kann
auch Textbl�cke (also Abschnitte) enthalten, die als
B<description> in das XML Dokument geschrieben werden. Wichtige
Werte, wie B<Autor>, B<Layout>, B<Lizenz>, B<Titel> und
B<Runlevel> werden hier ausgewertet.  Diese Schl�sselw�rter
stehen am Anfang einer Zeile
(normalerweise hinter "* ", der aus �bersichtlichkeitsgr�nden
dort steht) und enthalten nach einem Doppelpunkt einen Wert. Ein
Beispielheader:

=over 4

  <!--
  * mini - $Revision: 1.3 $
  * [c] Steffen Dettmer
  * Autor: Steffen Dettmer <steffen@dett.de>
  * Lizenz: GFDL
  ***
  -->
  <!-- plain2xml name: "Kommandoname" -->

=back
  
Im Header k�nnen auch Sonderkommandos stehen. Im Beispiel oben
wird definiert, das der Text B<Kommandoname> als Name aufgefa�t
werden soll (jedes Auftreten dieses Wortes wird in B<name> Tags
geklammert).

Nach der ersten �berschrift (oder vielen Leerzeilen) wird das
Ende des Headers angenommen. Textbl�cke vor der ersten
�berschrift werden zu B<description>.

Abschnitte, also Textbl�cke die durch eine Leerzeile getrennt
sind, k�nnen spezielle Typen haben. Ein Textblock kann
beispielsweise eine Liste darstellen. Diese Typen kann man �ber
Sonderkommandos einstellen.


=head2 Aufruf

./plain2xml.pl --file dokument


=head2 Fehler und Warnungen

Beim Einlesen und Interpretieren k�nnen Fehler und Warnungen
auftreten. Im B<strict>-Mode f�hren diese - je nach Einstellung -
zu einem Abbruch des Ablaufes.

Das Tool schreibt Warnungen, auch als Kommentar in die Ausgabe.
Der Clou: es wird die Zeilennummer aus der Eingabedatei mit
rangeschrieben. So wird gewarnt, wenn eine "�berschrift" (also
etwas nach drei Leerzeilen) keine Zahl vorn hat oder einen Punkt
am Ende ("1. Einleitung" z.B) und so weiter. Diese kann man dann 
abarbeiten.


=head2 Sonderfunktionen

Sonderfunktionen werden durch eine Steuerzeile definiert, die als
XML-Kommentar unter anderem das Schl�sselword B<plain2xml>
enthalten.

Im Header wird erkannt:

E<lt>!-- plain2xml B<command>: I<Kommando> --E<gt>

"Kommando" --E<gt> "E<lt>commandE<gt>KommandoE<lt>/commandE<gt>"

E<lt>!-- plain2xml B<name>:    I<Name> --E<gt>

"Name" --E<gt> "E<lt>nameE<gt>NameE<lt>/nameE<gt>"



In der ersten Zeile eines Textblockes wird erkannt:

E<lt>!-- plain2xml B<list>: --E<gt>

wird nach E<lt>ulE<gt>E<lt>liE<gt>E<lt>/liE<gt>E<lt>/ulE<gt>
konvertiert, momentan nur einzeilig
 
E<lt>!-- plain2xml B<table>: --E<gt>

experimentelle Tabelle; Jede Zeile des Textblockes gilt als
Tabellenzeile. Spalten werden durch "|" getrennt.
Um das E<lt>pdf-column/E<gt> Tag zu erhalten, dass f�r die PDF-Ausgabe
ben�tigt wird muss in der Anweisung ein B<column> Attribut gesetzt werden.
Man gibt mit dem column-Tag die genaue Anzahl der Spalten an. Hier folgt
ein Beispiel f�r eine Tabelle mit B<zwei> Spalten.

E<lt>!-- plain2xml table: B<column=2> --E<gt>




URL Erkennung:
 
Alles in der Form ftp://... und http://..., also "http" oder
"ftp", gefolgt von "://" bis zum n�chsten Leerzeichen, wird als
URL erkannt und mit einem B<ref>-Tag dargestellt.


=head1 Technischer Ablauf

Dieser Abschnitt dokumentiert die interne Funktionsweise und ist
f�r viele Anwender sicherlich weniger interessant.

=head2 Datei einlesen und zerlegen

Intern wird erst die Datei eingelesen. Intern werden daraus
B<Token> erzeugt. Token sind nicht n�her bestimmte Datenelemente,
die sp�ter genauer "ausgef�llt" werden. Dabei werden
Leerzeilen/Textwechsel als Token-Trenner genommen. Es entsteht
eine Liste mit alternierenden "text" und "blank" Token. 

Jeder "block" (Textbl�cke sind ja durch mindestens Leerzeile
getrennt) wird als Token in eine Liste eingetragen.
Dazwischen stehen Token, die die Leerzeilen repr�sentieren.

=head2 Tokenanalyse

In einem zweiten Durchlauf werden die Token analysiert und
�berschriften erkannt. Dabei werden auch die globalen
plain2xml-Header-Direktiven erkannt und in der Konfiguration
gespeichert.

"text"-Token ganz am Anfang (vor der ersten �berschrift) werden
zu "header"-Token (die sp�ter zu header oder zu B<description>
werden k�nnen).  Text-token, deren Vorg�nger ein blank mit der
"breite" 3 ist, werden "heading" Token (�berschriften). An der
Anzahl der "." vorn wird die Tiefe ("headingLevel") erraten.

=head2 Tokenstrukturierung

Im n�chsten Durchlauf wird aus der Tokenliste eine Struktur
gemacht. Die Token werden dabei als "elements" in einen Node
eingetragen. Die werden als hash refs benutzt. Das funktioniert
wie folgt:

Zun�chst werden alle Token einschlie�lich des letzten "header"
Tokens an das Wurzel-node als "header" geklebt. Das n�chste
Token wird an eine rekursiv arbeitende Funktion �bergeben.
Diese m�chte eine �berschrift, viele Textbl�cke bis zur zweiten
�berschrift als "elements" einh�ngen. 

Bei einer �berschrift (mit gr��erem Level) wird rekursiv
gerufen. Die Funktion ruft sich also sofort (kommt ja gleich ne
�berschrift) sich selbst auf, h�ngt �berschrift und textbl�cke
ein, bis ne �berschrift kommt. 

Ist deren level gr��er, ruft sie rekursiv f�r n�chste Ebene.
Dazu wird ein subnode erzeugt, in die Liste eingetragen und
der Funktion als "ihr" rootnode �bergeben. Kommt eine zweite
�berschrift gleicher Ordnung, ist eine section-Struktur
"voll", es wird zur�ckgesprungen. Der Aufrufer mu� das
Verarbeiten. Er merkt, huch, ist ja gar nicht meine Ordnung,
mu� also rekursiv rufen.  

Kommt ne �berschrift niederer Ordnung, wird einfach
zur�ckgehrt, solange, bis das level stimmt (also kleiner ist,
dann wird rekursiv gerufen).

=head2 Strukturverarbeitung

Bei der Strukturverarbeitung werden vorallem die Sonderkommandos
an Textbl�cken ausgewertet und vorverarbeitet, in dem die
betreffeneden Token ver�ndert werden.

=head2 XML-Ausgabe 

Der eigentliche XML Code entsteht bei der Ausgabe. Hier wird die
intern gespeicherte Struktur in eine XML Struktur umgewandelt.

Bei der Ausgabe wird das rootnode besonders behandelt, weil es
ein B<chapter> erzeugt. Rekursiv wird dann eine zweite Ausgabe
Funktion gerufen, die je eine B<section> aus einem subnode
(oder subsubnode etc.) erzeugt. Je nach type wird die Ausgabe
der elments anders. So werden Textbl�cke als B<textblock>, Listen
hingegen als B<list> geschrieben.

=head1 Interne Datenstrukturen

Dieser Abschnitt beschreibt die intern verwendeten
Datenstrukturen.

Wie bereits angedeutet, werden B<Token> verwendet. Das sind nicht
n�her bestimmte Datenelemente. Beim Einlesen werden
beispielsweise B<textblock>-Token erzeugt. Sp�ter k�nnen daraus
B<listblock> oder B<header>-Token werden. Intern werden Token als
Hashes gespeichert. Diese Token werden in einer Liste gespeichert
(genauer gesagt, Referenzen auf Token).

Ein B<token> hat immer einen 'type' (blank, header, textblock) und
andere Eigenschaften, meist 'sourceLine', 'headingLevel'.  'type'
=E<gt> 'blank' hat auch immer 'blank' =E<gt> anzahl (mind. 1)

Ein node hat type 'node' und immer 'elements' (ref to list).

Der root-node hat noch 'header' (der hat ne liste mit header
token) und 'start' (steht z.B. Dateiname und globales Zeug drin).

Ein Node kann in den 'elements' liste auch (sub)nodes haben.

Aus RFU gr�nden ist $structure ne liste (mit einem element).
Ach so, verwendet wird immer eine Referenz darauf, wie immer.

  Beispiel:

  $structure =  [ { } ]
  Eine ref to list mit einem element, das ist ref to hash. 
  Dieses eine Element ist der "root node":

  $rootnode = $structure->[0];

  $rootnode->{'type'} == 'node'

  Der root-Node hat 'header' und 'start':
  
  $headernode = $rootnode->{'header'};
  
    $headernode: ist ne ref to liste mit (refs zu) Tokens 
       (tokens sind hash refs)

    $headertoken = $headernode->[0];

      $headertoken->{'type'}
      $headertoken->{'value'} | $headertoken->{'blank'}
      $headertoken->{'sourceLine'}
      $headertoken->{'isHeader'} == 1 (oder fehler)

  $startToken = $rootnode->{'start'}
  
    $startToken->{'type'} == 'start' (sonst auch fehler)
    $startToken->{'license'}
    $startToken->{'author'}
    $startToken->{'filename'}
 
  Ein root-Node hat weiterhin viele 'elements':
 
  $rootnode->{'elements'} 
  Das ist eine ref to list mit tokens (die subnodes sein k�nnen):

  $someToken = $rootnode->{'elements'}->[0]

    $someToken->{'type'}
        Type des Tokens (blank, textblock, listblock, ...)
    $someToken->{'value'} | $someToken->{'blank'}
    $someToken->{'headingLevel'} 
        rootnode hat 0. textblock -> description)
    $someToken->{'sourceLine'}
        Zeile der Eingabedatei, der dieses Token erzeugte
    $someToken->{'textcontent'} 
        wahr, wenn es Textinhalt hat
    $someToken->{'warn'} 
        falls Warnungen an dem token waren

  Angenommen, das 7. element ist ein Token, da� einen Subnode
  darstellt:
  
  $nodeToken = $rootnode->{'elements'}->[7];
    
    $nodeToken->{'type'} == 'node'
    $nodeToken->{'headingLevel'} 
        Ist hier > 0
    $nodeToken->{'elements'}
        Die Elemente, also Token, die unter diesem Node liegen

    $otherToken = $nodeToken->{'elements'}->[0];

      $otherToken ist wie $someToken!
    


=head1 AUTHOR

Steffen Dettmer E<lt>steffen@dett.deE<gt>


=head1 COPYRIGHT

Copyright (c) 2003 Steffen Dettmer.

