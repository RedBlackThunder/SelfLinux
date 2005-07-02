/*
 * mksl3
 *
 * $Revision: 1.8 $
 * $Source: /selflinux/tools/mksl3/Filelist.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: Filelist.java,v 1.8 2004/04/07 14:17:27 florian Exp $
 */

// Importiere benoetigte Klassen
import java.io.*;
import java.util.*;

public class Filelist {
	static public ArrayList <String> dateiliste;
	
	static public void make(String xmlfile) {
		String sep = System.getProperty("file.separator");
		
		// Reserviere Speicherplatz fuer ArrayList dateiliste
		dateiliste = new ArrayList<String>();

		// <document> einlesen
		try {
			// Oeffne Inputstream fuer die XML-Datei
			FileInputStream fin = new FileInputStream(xmlfile);
			BufferedReader in = new BufferedReader(new InputStreamReader(fin));
			
			String document = "";
			String documenttag = "";
			String line;

			// Analysiere Inputstream
			while ((line = in.readLine()) != null) {
				// Ignoriere Kommentare
				if (line.matches("^.*<!---.*$")) {
					if (line.matches("^.*-->.*$")) {
						break;
					} else {
						while ((line = in.readLine()) != null) {
							if (line.matches("^.*-->.*$")) {
								break;
							}
						}						
					}
				}
				//	Extrahiere Document-Referenz
				if (line.matches("^.*<document.*file=.*/>$")) {
					documenttag=line;

					// Extrahiere den Dateipfad aus dem XML-Tag
					documenttag = documenttag.replaceAll("<document.*file=\"","");
					documenttag = documenttag.replaceAll("\"/>","");
					document = documenttag.trim();
					dateiliste.add( (String) document);
				}
			}
			
			// Schliesse Inputstream fuer die XML-Datei
			in.close();
		}
		// Fange Exception FileNotFound ab
		catch (FileNotFoundException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
		// Fange Exception IO ab
		catch (IOException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
	}
		
	static public String getfile(int i) {
		return (String) dateiliste.get(i);
	}
	
	static public int getanzahl() {
		return dateiliste.size();
	}
}
