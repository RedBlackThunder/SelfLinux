/*
 * mksl3
 *
 * $Revision: 1.2 $
 * $Source: /selflinux/tools/mksl3/NullOutputStream.java,v $
 * Autor: Florian Frank <florian.frank@pingos.org>
 *
 * Lizenz: GPL
 *
 *** $Id: NullOutputStream.java,v 1.2 2003/08/08 16:33:56 florian Exp $
 */

import java.io.*;

public class NullOutputStream extends OutputStream
{
   public void write (int b)
   {
	  // kein Code -- keine Ausgabe ;)
   }
}
