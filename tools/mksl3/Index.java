/*
 * mksl3
 *
 * $Revision: 1.11 $
 * $Source: /selflinux/tools/mksl3/Index.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: Index.java,v 1.11 2004/04/07 14:17:27 florian Exp $
 */

// Importiere benoetigte Klassen
import java.io.*;
import javax.xml.transform.stream.*;
import javax.xml.transform.*;
import com.icl.saxon.FeatureKeys;

public class Index {

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
			
			// Erzeuge eine Instanz von transformerfactory
			TransformerFactory tfactory = TransformerFactory.newInstance();

			// Setze Attribute fuer transformerfactory
			tfactory.setAttribute(FeatureKeys.LINE_NUMBERING, new Boolean(true));

			// Erzeuge einen transformer fuer das Stylesheet
			Transformer transformer = tfactory.newTransformer(xslsource);
		
			// Setzte Parameter fuer transformer
			transformer.setParameter("pwd", mksl3.basedir+sep+"tutorial");
			transformer.setParameter("dest", mksl3.outputdir+sep+"index.xml");
			
			if (mksl3.silent==true) {
				transformer.setParameter("silent", "true");
			} else {
				transformer.setParameter("silent", "false");
			}

			// Uebersetze XML
			transformer.transform(xmlsource, new StreamResult(new NullOutputStream()));
		
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
		// Fang Exception Transformer ab
		catch (TransformerException ex) {
			System.err.println("\nFEHLER: "+ex.getMessage()+"\n");
			System.exit(1);
		}
	}
}
