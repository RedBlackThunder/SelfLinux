/*
 * mksl3
 *
 * $Revision: 1.19 $
 * $Source: /selflinux/tools/mksl3/mksl3.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: mksl3.java,v 1.19 2004/04/07 14:17:27 florian Exp $
 */
 
 // Importiere benoetigte Klassen
import java.io.*;
import java.util.*;
import java.text.*;

public class mksl3 {
	public static String variant;
	public static String basedir;
	public static String outputdir;
	public static String version;
	public static Filelist filelist;
	public static Document[] documents;

	public static boolean filemode=false;
	public static String[] files;

	public static boolean make_html = false;
	public static boolean make_pdf = false;
	public static boolean validate = false;
	public static boolean silent = false;
	public static boolean debug  = false;

	public static void main(String[] args) {
		String sep = System.getProperty("file.separator");

		boolean printhelp = false;
		
		// Analysiere Parameteruebergaben
		for (int i=0; i<args.length; i++) {
			if (args[i].equals("-h")) {
				printhelp=true;
			}
			if (args[i].equals("--help")) {
				printhelp=true;
			}
			if (args[i].equals("--silent")) {
				silent=true;
			}
			if (args[i].equals("--debug")) {
				debug=true;
			}
			if (args[i].startsWith("--basedir=")) {
				basedir=args[i].substring(args[i].indexOf("=")+1, args[i].length());
			}
			if (args[i].startsWith("--outputdir=")) {
				outputdir=args[i].substring(args[i].indexOf("=")+1, args[i].length());
			}
			if (args[i].startsWith("--variant=")) {
				variant=args[i].substring(args[i].indexOf("=")+1, args[i].length());
			}
			if (args[i].startsWith("--version=")) {
				version="SelfLinux-"+args[i].substring(args[i].indexOf("=")+1, args[i].length());
			}
			if (args[i].equals("--html")) {
				make_html=true;
			}
			if (args[i].equals("--pdf")) {
				make_pdf=true;
			}
			if (args[i].equals("--validate")) {
				validate=true;
			}
			if (args[i].startsWith("--file=")) {
				filemode=true;
				String tmp=args[i].substring(args[i].indexOf("=")+1, args[i].length());
				if (tmp.matches(".*,.*")==true) {
					files=tmp.split(",");
				} else {
					files=new String[1];
					files[0]=tmp;
				}
			}
		}

		// Hilfe anzeigen?
		if ( (printhelp==true) ||
				(basedir==null || basedir=="") ||
				(outputdir==null || outputdir=="") ||
				(make_html==true && (variant==null || variant=="")) ) {
			System.err.println("Usage:");
			System.err.println("Generate full release:");
			System.err.println("    java mksl3 [--silent] [--debug] --variant=[online|download] --basedir=<absolute path> --outputdir=<absolut path> [--version=x.x.x] [--file=<relative path>[,<relative path>]]");
			System.err.println("");
			System.err.println("Generate HTML-output:");
			System.err.println("    java mksl3 --html [--silent] [--debug] --variant=[online|download] --basedir=<absolut path> --outputdir=<absolute path> [--version=x.x.x] [--file=<relative path>[,<relative path>]]  [--version=x.x.x]");
			System.err.println("Generate PDF-output:");
			System.err.println("    java mksl3 --pdf [--silent] --basedir=<absolute path> --outputdir=<absolute path> [--version=x.x.x] [--file=<relative path>[,<relative path>]]");
			System.err.println("Validate XML-files:");
			System.err.println("    java mksl3 --validate --basedir=<absolute path> --outputdir=<absolute path> [--file=<relative path>[,<relative path>]]");
			System.err.println("");
			System.exit(1);
		}
		
		if ((make_html==false) && (make_pdf==false) && (validate==false)) {
			make_html=true;
			make_pdf=true;
			validate=true;
		}
		
		// Überprüfe Versionsnummer
		if (version==null || version=="") {
			SimpleDateFormat SLDateFormat = new SimpleDateFormat("yyyyMMdd");
			Date date = new Date();
			version="SelfLinux-"+SLDateFormat.format(date);
		}
		System.out.println("Version: "+version);

		// Erzeuge Verzeichnis outputdir
		System.out.print("Erzeuge Verzeichnis "+outputdir+" ... ");
		File td = new File(outputdir);
		td.mkdir();
		System.out.println("erledigt");

		// Erzeuge Dateiliste
		if (filemode==false) {
			System.out.print("Erzeuge Dateiliste ... ");
			Filelist.make(basedir+sep+"tutorial"+sep+"index.xml");
			System.out.println("erledigt");
		}
		
		// Erzeuge index.xml
		System.out.print("Erzeuge index.xml ...");
		Index.make(basedir+sep+"tutorial"+sep+"index.xml",basedir+sep+"stylesheets"+sep+"html"+sep+"index.xsl");
		System.out.println("erledigt");

		// Erzeuge weitere Ausgabeverzeichnisse
		if (make_html==true || make_pdf==true) {
			System.out.print("Erzeuge Verzeichnis: "+outputdir+sep+version+" ... ");
			File td1 = new File(outputdir+sep+version);
			td1.mkdir();
			System.out.println("erledigt");
		}
		if (make_html==true) {
			System.out.print("Erzeuge Verzeichnis: "+outputdir+sep+version+sep+"bilder ... ");
			File td2 = new File(outputdir+sep+version+sep+"bilder");
			td2.mkdir();
			System.out.println("erledigt");

			System.out.print("Erzeuge Verzeichnis: "+outputdir+sep+version+sep+"html ... ");
			File td3 = new File(outputdir+sep+version+sep+"html");
			td3.mkdir();
			System.out.println("erledigt");
		}
		if (make_pdf==true) {
			System.out.print("Erzeuge Verzeichnis: "+outputdir+sep+version+sep+"pdf ... ");
			File td4 = new File(outputdir+sep+version+sep+"pdf");
			td4.mkdir();
			System.out.println("erledigt");
		}
		
		// Setze und kompiliere Stylesheets fuer die Dokumenten-Objekte
		if (make_html==true || make_pdf==true) {
			System.out.print("Setzen und kompilieren der Stylesheets ... ");
			if (make_html==true) {
				Document.set_xsl2htmlfile(basedir+sep+"stylesheets"+sep+"html"+sep+"main.xsl");
			}
			if (make_pdf==true) {
				Document.set_xsl2pdffile(basedir+sep+"stylesheets"+sep+"pdf"+sep+"main.xsl");
			}
			System.out.println("erledigt");
		}
		
		// Setze xsd-Datei zum Validieren
		if (validate==true) {
			System.out.print("Setze xsd-Datei zum Validieren ... ");
			Document.set_xsdfile(basedir+sep+"stylesheets"+sep+"xsd"+sep+"selflinux.xsd");
			System.out.println("erledigt");
		}
		
		// Erzeuge aus den Texten Objekte
		System.out.print("Erzeuge aus den Texten Objekte ... ");
		if (filemode==true) {
			documents = new Document[files.length];
			for (int i=0; i<files.length; i++) {
				documents[i] = new Document(basedir+sep+"tutorial"+files[i]);
			}
		} else {
			documents = new Document[Filelist.getanzahl()];
			for (int i=0; i<Filelist.getanzahl(); i++) {
				documents[i]= new Document(basedir+sep+"tutorial"+Filelist.getfile(i));
			}
		}
		System.out.println("erledigt");

		if (make_html==true) {
			// Kopiere Icons in das Release
			System.out.print("Kopiere Icons (");
			Icons.copy(basedir+sep+"stylesheets"+sep+"html"+sep+"bilder"+sep+"index");
			System.out.println(") ... erledigt");

			if (filemode==false) {
				// Erzeuge Inhaltsverzeichnisse
				System.out.print("Erzeuge Inhaltsverzeichnisse ... ");
				Dirs.make(outputdir+sep+"index.xml",basedir+sep+"stylesheets"+sep+"html"+sep+"dirs.xsl");
				System.out.println("erledigt");

				// Erzeuge Linkübersicht
				if (debug==true) {
					System.out.print("Erzeuge externes Linkverzeichnis ... ");
					DebugLinks.make(outputdir+sep+"index.xml",basedir+sep+"stylesheets"+sep+"html"+sep+"debuglinks.xsl");
					System.out.println("erledigt");
				}
			}
		}

		int anzahl;
		if (filemode==true) {
			anzahl=files.length;
		} else {
			anzahl=Filelist.getanzahl();
		}

		for (int i=0; i<anzahl; i++) {
			System.out.println();
			System.out.println("Bearbeite Text: "+documents[i].getindex());
			if (validate==true) {
				// Text validieren
				System.out.print("Validiere Text ... ");
				documents[i].validate();
				System.out.println("erledigt");
			}
			if (make_pdf==true) {
				// Text in PDF uebersetzen
				if (silent==true) {
					System.out.print("Uebersetze Text in PDF ...");
				} else {
					System.out.println("Uebersetze Text in PDF ...");
				}
				if ( (i & 5) == 0) {
					org.apache.fop.image.FopImageFactory.resetCache();
				}
				documents[i].makepdf();
				if (silent==true) {
					System.out.println(" erledigt");
				} else {
					System.out.println("... erledigt");
				}
			}
			if (make_html==true) {
				// Text in HTML uebersetzen
				if (silent==true) {
					System.out.print("Uebersetze Text in HTML ...");
				} else {
					System.out.println("Uebersetze Text in HTML ...");
				}
				documents[i].makehtml();
				if (silent==true) {
					System.out.println(" erledigt");
				} else {
					System.out.println("... erledigt");
				}
			}
		}
		System.out.println("\nmksl3 erfolgreich beendet.\n");
	}
}
