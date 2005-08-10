/*
 * mksl3
 *
 * $Revision: 1.14 $
 * $Source: /selflinux/tools/mksl3/Document.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: Document.java,v 1.14 2004/04/07 14:17:27 florian Exp $
 */

// Importiere benoetigte Klassen
import java.io.*;
import java.util.*;
import javax.xml.transform.sax.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.*;
import org.xml.sax.*;
import org.xml.sax.helpers.*;
import com.icl.saxon.FeatureKeys;

import org.apache.avalon.framework.logger.ConsoleLogger;
import org.apache.avalon.framework.logger.Logger;

import org.apache.fop.apps.Driver;
import org.apache.fop.messaging.MessageHandler;

public class Document {
	public static String xsl2htmlfile;
	public static String xsl2pdffile;
	public static String xsdfile;
	private static Templates pdfstylesheet;
	private static Templates htmlstylesheet;
	private static String[] types = {"B","KB","MB","GB","TB"};
	private static Driver pdfdriver;
	private static ArrayList <String> indexlist;

	private String xmlfile;
	private String pdffile;
	private String index;
	private ArrayList <String> images;
	private String pdfsize;

	static public void set_xsl2htmlfile(String file) {
		xsl2htmlfile = file;
		
		try {
			// Oeffne Inputstream fuer das Stylesheet
			InputStream xslstream = new BufferedInputStream(new FileInputStream(xsl2htmlfile));
			StreamSource xslsource = new StreamSource(xslstream);
			// Setze Verzeichnis zum Stylesheet wegen evtl. relativen Pfaden
			xslsource.setSystemId("file:"+xsl2htmlfile);

			// Erzeuge neue Transformerfactory
			TransformerFactory tfactory = TransformerFactory.newInstance();

			// Setze Attribute fuer transformerfactory
			tfactory.setAttribute(FeatureKeys.LINE_NUMBERING, new Boolean(true));

			// Erzeuge kompiliertes Stylesheet
			htmlstylesheet = tfactory.newTemplates(xslsource);
			
			// Schliesse Inputstream fuer das Stylesheet
			xslstream.close();
		}
		//	Fange Exception FileNotFound ab
		catch (FileNotFoundException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
	 	}
		// Fange Exception IO ab
	 	catch (IOException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
	 	}
	 	// Fange Exception Transformer ab
	 	catch (TransformerException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
	 	}
	}

	static public void set_xsl2pdffile(String file) {
		xsl2pdffile = file;
		
		try {
			// Oeffne Inputstream fuer das Stylesheet
			InputStream xslstream = new BufferedInputStream(new FileInputStream(xsl2pdffile));
			StreamSource xslsource = new StreamSource(xslstream);
			// Setze Verzeichnis zum Stylesheet wegen evtl. relativen Pfaden
			xslsource.setSystemId("file:"+xsl2pdffile);

			// Erzeuge neue Transformerfactory
			TransformerFactory tfactory = TransformerFactory.newInstance();
			
			// Erzeuge kompiliertes Stylesheet
			pdfstylesheet = tfactory.newTemplates(xslsource);
			
			// Schliesse Inputstream fuer das Stylesheet
			xslstream.close();
		}
		//	Fange Exception FileNotFound ab
		catch (FileNotFoundException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
		//	Fange Exception IO ab
		catch (IOException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
	 	// Fange Exception Transformer ab
	 	catch (TransformerException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
	 	}
	}

	static public void set_xsdfile(String file) {
		xsdfile = file;
	}
	
	public String getindex() {
		return index;
	}
	
	private String getxmlfile() {
		return xmlfile;
	}
	
	public Document(String xml) {
		String sep = System.getProperty("file.separator");
		xmlfile = xml;

		// <index> und <image> einlesen
		
		//Reserviere Speicher fuer ArrayList indexlist
		if (indexlist==null) {
			indexlist = new ArrayList<String>();
		}
		
		// Reserviere Speicher fuer ArrayList images
		images = new ArrayList<String>();
		try {
			// Oeffne Inputstream fuer die XML-Datei
			FileInputStream fin = new FileInputStream(xmlfile);
			BufferedReader in = new BufferedReader(new InputStreamReader(fin));
			
			String indextag = "";
			String imagetag = "";
			String line;
			
			// Analysiere Inputstream
			while ((line = in.readLine()) != null) {
				// Ignoriere Kommentare
				if (line.matches("^.*<!--.*$")) {
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
				//	Extrahiere Index-Referenz
				if (line.matches("^.*<index>.*$")) {
					if (line.matches("^.*</index>.*$")) {
						indextag=line;
					} else {
						indextag=line;
						while ((line = in.readLine()) != null) {
							indextag=indextag+line;
							if (line.matches("^.*</index>.*$")) {
								break;
							}
						}
					}
					// Extrahiere den Index-Namen aus dem XML-Tag
					indextag = indextag.replaceAll("</?index>","");
					index = indextag.trim();
					
					// Ueberpruefe auf Namenskollision
					boolean kollision=false;
					if (indexlist!=null && indexlist.size()>0) {
						for (int i=0; i<indexlist.size(); i++) {
							if (index.equals(indexlist.get(i))) {
								kollision=true;
								break;
							}
						}
					}
					
					if (kollision==true) {
						System.err.println("\nFEHLER: Namenskollision gefunden:\n");
						System.err.println("Index: "+index);
						System.err.println("Datei: "+xmlfile);
						System.exit(1);
					} else {
						indexlist.add(index);
					}
					
					// Setze pdffile anhand des Index-Namens
					pdffile = mksl3.outputdir+sep+mksl3.version+sep+"pdf"+sep+index+".pdf";
				}

				// Extrahiere Bilder-Referenzen
				if (line.matches("^.*<image.*$")) {
					if (line.matches("^.*</image>.*$")) {
						imagetag=line;
					} else {
						imagetag=line;
						while ((line = in.readLine()) != null) {
							imagetag=imagetag+line;
							if (line.matches("^.*</image>.*$")) {
								break;
							}
						}
					}
					// Extrahiere den Dateinamen aus dem XML-Tag
					imagetag = imagetag.replaceAll("<image.*<filename>","");
					imagetag = imagetag.replaceAll("</filename>.*</image>","");
					images.add(imagetag.trim());
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
		
		// Test ob das statische Driver-Objekt pdfdriver bereits existiert
		if (pdfdriver==null) {
			// Erzeuge PDF-Driver
			pdfdriver = new Driver();
		
			// Richte Logger fuer PDF-Driver ein
			if (mksl3.silent==true) {
				Logger logger = new ConsoleLogger(ConsoleLogger.LEVEL_ERROR);
				pdfdriver.setLogger(logger);
				MessageHandler.setScreenLogger(logger);
			} else {
				Logger logger = new ConsoleLogger(ConsoleLogger.LEVEL_INFO);
				pdfdriver.setLogger(logger);
				MessageHandler.setScreenLogger(logger);
			}
		
			// Richte Renderer fuer PDF-Driver ein
			pdfdriver.setRenderer(Driver.RENDER_PDF);
		}
	}
	
	private void copyimages() {
		String sep = System.getProperty("file.separator");
	
		// Test auf Existenz von referenzierten Bildern
		if (images != null && images.size()>0) {
			if (mksl3.silent==false) {
				System.out.print("Installiere Bilder:");
			}
			for (int i=0; i<images.size(); i++) {
				try {
					// Oeffne Inputstream zum Kopieren
					InputStream in = new FileInputStream(xmlfile.substring(0,xmlfile.lastIndexOf(sep))+sep+images.get(i));
					in = new BufferedInputStream(in);

					// Oeffne Outputstream zum Kopieren
					OutputStream out = new FileOutputStream(mksl3.outputdir+sep+mksl3.version+sep+"bilder"+sep+index+"_"+images.get(i));
					out = new BufferedOutputStream(out);
						
					// Gebe Dateinamen zur Kontrolle auf stdout aus
					if (mksl3.silent==false) {
						System.out.print(" "+(String) images.get(i));
					}

					// Kopieren starten
					int c;
					while ((c=in.read()) != -1) {
						out.write(c);
					}
						
					// Schliesse Inputstream zum Kopieren
					in.close();
					// Schliesse Outputstream zum Kopieren
					out.close();
				}
				//	Fange Exception FileNotFound ab
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
			if (mksl3.silent==false) {
				System.out.println(" ... erledigt");
			}
		}
	}

	public void makehtml() {
		String sep = System.getProperty("file.separator");
		
		// Kopiere in der XML-Datei referenzierte Bilder
		copyimages();
		
		try {
			// Oeffne Inputstream fuer die XML-Datei
			InputStream xmlstream = new BufferedInputStream(new FileInputStream(xmlfile));
			StreamSource xmlsource = new StreamSource(xmlstream);
			// Setze Verzeichnis zur XML-Datei wegen evtl. relativen Pfaden
			xmlsource.setSystemId("file:"+xmlfile);

			// Erzeuge neue Instanz von Transformer
			Transformer transformer = htmlstylesheet.newTransformer();

			// Setzte Parameter fuer transformer
			transformer.setParameter("version", mksl3.version);
			transformer.setParameter("variant", mksl3.variant);
			transformer.setParameter("pdfsize", pdfsize);
			transformer.setParameter("html_dir", mksl3.outputdir+sep+mksl3.version+sep+"html");
			transformer.setParameter("index", mksl3.outputdir+sep+"index.xml");

			if (mksl3.silent==true) {
				transformer.setParameter("silent", "true");
			} else {
				transformer.setParameter("silent", "false");
			}

			// Uebersetze XML
			transformer.transform(xmlsource, new StreamResult(new NullOutputStream()));

			// Schliesse Inputstream fuer die XML-Datei
			xmlstream.close();
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
		// Fange Exception Transformer ab
		catch (TransformerException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
	}
	
	public void makepdf() {
		String sep = System.getProperty("file.separator");
		
		// PDF-Driver zuruecksetzen
		pdfdriver.reset();
				
		// Konfiguration des Arbeitsverzeichnisses fuer relative Pfade
		org.apache.fop.configuration.Configuration.put("baseDir",xmlfile.substring(0,xmlfile.lastIndexOf(sep)));
	
		try {
			// Oeffne Inputstream fuer die XML-Datei
			InputStream xmlstream = new BufferedInputStream(new FileInputStream(xmlfile));
			StreamSource xmlsource = new StreamSource(xmlstream);
			// Setze Verzeichnis zur XML-Datei wegen evtl. relativen Pfaden
			xmlsource.setSystemId("file:"+xmlfile);

			// Oeffne Outputstream fuer die PDF-Datei
			OutputStream out = new FileOutputStream(pdffile);
			out = new BufferedOutputStream(out);
			
			// Setze Ausgabe in PDF-Datei
			pdfdriver.setOutputStream(out);

			// Erzeuge einen transformer fuer das Stylesheet
			Transformer transformer = pdfstylesheet.newTransformer();

			// Setzte Parameter fuer transformer
			transformer.setParameter("version", mksl3.version);
			transformer.setParameter("img_dir", xsl2pdffile.substring(0,xsl2pdffile.lastIndexOf(sep))+"/bilder");

			if (mksl3.silent==true) {
				transformer.setParameter("silent", "true");
			} else {
				transformer.setParameter("silent", "false");
			}
			
			// SAX Events an FOP weitergeben
			Result res = new SAXResult(pdfdriver.getContentHandler());
			
			// XSLT-Tranformation und FOP starten
			transformer.transform(xmlsource, res);
			
			// Schliesse InputStream fuer die XML-Datei
			xmlstream.close();
			
			// Schliesse Outputstream fuer die PDF-Datei
			out.close();
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
		// Fange Exception Transformer ab
		catch (TransformerException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);			
		}

		// Lese Groesse der PDF-Datei ein
		File f = new File(pdffile);
		long size = f.length();
		int current = 0;
		while (size >= 1024) {
			current++;
			size = size / 1024;
		}
		pdfsize = size + " " + types[current];
	}
	
	public void validate() {
		String sep = System.getProperty("file.separator");

		// Setze Einstellungen fuer xerces
		String parserClass = "org.apache.xerces.parsers.SAXParser";
		String validationFeature = "http://xml.org/sax/features/validation";
		String schemaFeature  = "http://apache.org/xml/features/validation/schema";
		try {
				 XMLReader r = XMLReaderFactory.createXMLReader(parserClass);
				 r.setFeature(validationFeature,true);
				 r.setFeature(schemaFeature,true);
				 r.setProperty("http://apache.org/xml/properties/schema/external-noNamespaceSchemaLocation",xsdfile);
				 r.parse(xmlfile);
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
		// Fange Exception SAX ab
		catch (SAXException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
	}
}
