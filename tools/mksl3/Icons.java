/*
 * mksl3
 *
 * $Revision: 1.7 $
 * $Source: /selflinux/tools/mksl3/Icons.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: Icons.java,v 1.7 2004/04/07 14:17:27 florian Exp $
 */
 
 import java.io.*;

public class Icons {
	
	public static void copy(String indexfile) {
		String sep = System.getProperty("file.separator");

		// <image> einlesen
		try {
			// Oeffne Inputstream  fuer den Bilder-Index
			FileInputStream fin = new FileInputStream(indexfile);
			BufferedReader in = new BufferedReader(new InputStreamReader(fin));

			String imagetag = "";
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
					imagetag = imagetag.trim();
					
					// Gebe Dateinamen zur Kontrolle auf stdout aus
					System.out.print(" "+imagetag+" ");
					
					// Oeffne Inputstream zum Kopieren
					InputStream iin = new FileInputStream(indexfile.substring(0,indexfile.lastIndexOf(sep))+sep+imagetag);
					iin = new BufferedInputStream(iin);

					// Oeffne Outputstream zum Kopieren
					OutputStream iout = new FileOutputStream(mksl3.outputdir+sep+mksl3.version+sep+"bilder"+sep+imagetag);
					iout = new BufferedOutputStream(iout);
					
					// Kopieren starten
					int c;
					while ((c=iin.read()) != -1) {
						iout.write(c);
					}
					
					// Schliesse Inputstream zum Kopieren
					iin.close();
					// Schliesse InputStream zum Kopieren
					iout.close();
				}
			}
			// Schliesse InputStream fuer den Bilder-Index
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
}