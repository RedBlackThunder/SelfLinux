/*
 * mksl3
 *
 * $Revision: 1.4 $
 * $Source: /selflinux/tools/mksl3/DebugLinks.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 * Erweiterung: Johannes Kolb <johannes.kolb@web.de>
 *
 * Lizenz: GPL
 *
 *** $Id: DebugLinks.java,v 1.4 2004/04/07 14:17:27 florian Exp $
 */

import java.io.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.*;
import com.icl.saxon.FeatureKeys;

public class DebugLinks {
	static public void make(String xmlfile, String xslfile) {
		String sep = System.getProperty("file.separator");

		try {
			// Oeffne Inputstream fuer das Stylesheet
			InputStream xslstream = new BufferedInputStream(new FileInputStream(xslfile));
			StreamSource xslsource = new StreamSource(xslstream);
			// Setze Verzeichnis zum Stylesheet wegen evtl. relativen Pfaden
			xslsource.setSystemId("file:"+xslfile);
			
			// Oeffne Inputstream fuer die XML-Datei
			InputStream xmlstream = new BufferedInputStream(new FileInputStream(xmlfile));
			StreamSource xmlsource = new StreamSource(xmlstream);
			// Setze Verzeichnis zur XML-Datei wegen evtl. relativen Pfaden
			xmlsource.setSystemId("file:"+xmlfile);
			
			// Oeffne Outputstream
			OutputStream out = new BufferedOutputStream(new FileOutputStream(mksl3.outputdir+sep+mksl3.version+sep+"html"+sep+"all-links.html"));
			StreamResult outstream = new StreamResult(out);
			
			// Erzeuge eine Instanz von transformerfactory
			TransformerFactory tfactory = TransformerFactory.newInstance();

			// Setze Attribute für transformerfactory
			tfactory.setAttribute(FeatureKeys.LINE_NUMBERING, new Boolean(true));

			// Erzeuge einen transformer fuer das Stylesheet
			Transformer transformer = tfactory.newTransformer(xslsource);
		
			// Uebersetze XML
			transformer.transform(xmlsource, outstream);
		
			// Schliesse Inputstream fuer das Stylesheet
			xslstream.close();
			// Schliesse InputStream fuer die XML-Datei
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
}
