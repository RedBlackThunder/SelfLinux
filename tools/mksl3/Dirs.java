/*
 * mksl3
 *
 * $Revision: 1.4 $
 * $Source: /selflinux/tools/mksl3/Dirs.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: Dirs.java,v 1.4 2004/04/07 14:17:27 florian Exp $
 */
 
// Importiere benoetigte Klassen

import java.io.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.*;

public class Dirs {

	public static void make(String xmlfile, String xslfile) {
		String sep = System.getProperty("file.separator");
		
		try {
			// Oeffne Inputstream fuer das Stylesheet
			InputStream xslstream = new BufferedInputStream(new FileInputStream(xslfile));
			StreamSource xslsource = new StreamSource(xslstream);
			//	Setze Verzeichnis zum Stylesheet wegen evtl. relativen Pfaden
			xslsource.setSystemId("file:"+xslfile);

			// Oeffne Inputstream fuer die XML-Datei
			InputStream xmlstream = new BufferedInputStream(new FileInputStream(xmlfile));
			StreamSource xmlsource = new StreamSource(xmlstream);
			//	Setze Verzeichnis zur XML-Datei wegen evtl. relativen Pfaden
			xmlsource.setSystemId("file:"+xmlfile);
			
			// Oeffne Outputstream
			OutputStream out = new BufferedOutputStream(new FileOutputStream(mksl3.outputdir+sep+mksl3.version+sep+"index.html"));
			StreamResult outstream = new StreamResult(out);
			
			// Erzeuge eine Instanz von transform factory
			TransformerFactory tfactory = TransformerFactory.newInstance();
			
			// Erzeuge einen transformer fuer das Stylesheet
			Transformer transformer = tfactory.newTransformer(xslsource);
			
			// Setzte Parameter fuer transformer
			transformer.setParameter("version", mksl3.version);
			transformer.setParameter("variant", mksl3.variant);
			transformer.setParameter("index", mksl3.outputdir+sep+"index.xml");
			transformer.setParameter("html_dir", mksl3.outputdir+sep+mksl3.version+sep+"html");

			if (mksl3.silent==true) {
				transformer.setParameter("silent", "true");
			} else {
				transformer.setParameter("silent", "false");
			}

			// Uebersetze XML
			transformer.transform(xmlsource, outstream);
		
			// Schliesse Inputstream fuer das Stylesheet
			xslstream.close();
			// Schliesse Inputstream fuer die XML-Datei
			xmlstream.close();
		}
		// Fange Exception FileNotFound ab
		catch (FileNotFoundException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage());
			System.exit(1);
		}
		// Fange Exception IO ab
		catch (IOException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage());
			System.exit(1);
		}
		// Fange Exception Transformer ab
		catch (TransformerException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage());
			System.exit(1);
		}
	}
}
