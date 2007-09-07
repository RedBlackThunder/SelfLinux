<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * lib.xsl - Hilfstemplates für die anderen Stylesheet-Dateien
 * Copyright Peter Schneewind, Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.48 $
 * $Source: /selflinux/stylesheets/html/lib.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: lib.xsl,v 1.48 2004/05/25 20:54:47 florian Exp $
-->

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon"
 encoding="ISO-8859-1">

 <!--
  Benanntes Template zur Ausgabe des SelfLinux-Dokumentenheaders
 -->
 <xsl:template name="do_copyright">
  <xsl:comment>
 * <xsl:value-of select="normalize-space(/chapter/index)"/>
 * Copyright <xsl:for-each select="/chapter/author">
    <xsl:value-of select="normalize-space(name)"/>
    <xsl:if test="not(position() = last())">
     <xsl:text>, </xsl:text>
    </xsl:if>
   </xsl:for-each>
   <xsl:if test="/chapter/license">
 * Lizenz: <xsl:value-of select="normalize-space(/chapter/license)"/>
   </xsl:if>
 *
 * <xsl:value-of select="$version"/>
 *
 * Diese Datei ist Teil von SelfLinux http://www.selflinux.org
 *
  </xsl:comment>
 </xsl:template>

 <xsl:variable name="index_file">
  <xsl:value-of select="normalize-space(/chapter/index)"/>
 </xsl:variable>

 <xsl:template name="chapter_path">
  <xsl:if test="$index!='none'">
   <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
   <xsl:text>&#160;</xsl:text>
   <a href="../index.html">SelfLinux</a>
    <xsl:for-each select="document($index)//directory[descendant::chapter[@index=$chapter_index]]">
    <xsl:text>&#160;</xsl:text>
    <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
    <xsl:text>&#160;</xsl:text>
    <a>
     <xsl:attribute name="href">
      <xsl:value-of select="@file"/>
      <xsl:text>.html</xsl:text>
     </xsl:attribute>
     <xsl:value-of select="normalize-space(@title)"/>
    </a>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>

 <!--
  Benannte Vorlage zur Ausgabe der Kopfzeile einer Seite
 -->

 <xsl:template name="do_headline">
  <table width="95%" align="center">
   <tr>
    <td align="left">
     <xsl:call-template name="chapter_path"/>
     <xsl:text>&#160;</xsl:text>
     <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
     <xsl:text>&#160;</xsl:text>
     <xsl:choose>
      <xsl:when test="self::chapter or count(//split/section) = 1">
       <xsl:value-of select="/chapter/title"/>
      </xsl:when>
      <xsl:otherwise>
       <a href="{$index_file}.html">
        <xsl:value-of select="/chapter/title"/>
       </a>
       <xsl:text>&#160;</xsl:text>
       <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
       <xsl:text>&#160;</xsl:text>
       <xsl:choose>
        <xsl:when test="count(//split) = 1">
         <xsl:text>Text</xsl:text>
        </xsl:when>
        <xsl:otherwise>
         <xsl:text>Abschnitt </xsl:text><xsl:number/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:otherwise>
     </xsl:choose>
    </td>
    <td align="right">
     <xsl:value-of select="$version"/>
    </td>
   </tr>
   <tr>
    <td bgcolor="#c9d8e5" colspan="2">
     <table width="100%">
      <xsl:call-template name="do_prevnext">
       <xsl:with-param name="pos">top</xsl:with-param>
      </xsl:call-template>
     </table>
    </td>
   </tr>
  </table>
  <br/>
 </xsl:template>

 <!--
  Benannte Vorlage zur Ausgabe des Seitenheaders
 -->

 <xsl:template name="do_header">
  <tr>
   <td width="120">
    <img width="112" height="124" alt="SelfLinux-Logo">
     <xsl:attribute name="src">
      <xsl:value-of select="$img_dir"/>
      <xsl:text>/selflinux.png</xsl:text>
     </xsl:attribute>
    </img>
   </td>
   <td align="left" valign="middle" bgcolor="#f5f5f5" width="100%">
    <table width="100%">
     <tr>
      <td width="44">
       <img width="30" height="44" hspace="20" align="middle" alt="Dokument">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/document.png</xsl:text>
        </xsl:attribute>
       </img>
      </td>
      <td align="left">
       <font size="+1">
        <xsl:value-of select="/chapter/title"/>
        <xsl:if test="self::split and count(/split/section) > 1">
         <xsl:text> - Abschnitt </xsl:text><xsl:number/>
        </xsl:if>
       </font>
      </td>
      <td align="right">
       <xsl:choose>
        <xsl:when test="count(/chapter/author) = 1">
         <img width="10" height="10" alt="">
          <xsl:attribute name="src">
           <xsl:value-of select="$img_dir"/>
           <xsl:text>/intern2.png</xsl:text>
          </xsl:attribute>
         </img>
         <xsl:text>&#160;</xsl:text>
         <a>
          <xsl:attribute name="href">
           <xsl:value-of select="normalize-space(/chapter/index)"/>
           <xsl:text>.html#author</xsl:text>
          </xsl:attribute>
          <xsl:text>Autor</xsl:text>
         </a>
        </xsl:when>
        <xsl:otherwise>
         <img width="10" height="10" alt="">
          <xsl:attribute name="src">
           <xsl:value-of select="$img_dir"/>
           <xsl:text>/intern2.png</xsl:text>
          </xsl:attribute>
         </img>
         <xsl:text>&#160;</xsl:text>
         <a>
          <xsl:attribute name="href">
           <xsl:value-of select="normalize-space(/chapter/index)"/>
           <xsl:text>.html#author</xsl:text>
          </xsl:attribute>
          <xsl:text>Autoren</xsl:text>
         </a>
        </xsl:otherwise>
       </xsl:choose>
       <br/>

       <img width="10" height="10" alt="">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/intern2.png</xsl:text>
        </xsl:attribute>
       </img>
       <xsl:text>&#160;</xsl:text>
       <a>
        <xsl:attribute name="href">
         <xsl:value-of select="normalize-space(/chapter/index)"/>
         <xsl:text>.html#layout</xsl:text>
        </xsl:attribute>
        <xsl:text>Formatierung</xsl:text>
       </a>
       <br/>

       <xsl:choose>
        <xsl:when test="normalize-space(/chapter/license) = 'GFDL'">
         <img src="../bilder/intern2.png" width="10" height="10" alt="" title=""/>
         <xsl:text>&#160;</xsl:text>
         <a href="gfdl_de.html">
          <xsl:value-of select="normalize-space(/chapter/license)"/>
         </a>
        </xsl:when>
        <xsl:when test="normalize-space(/chapter/license) = 'GPL'">
         <img src="../bilder/intern2.png" width="10" height="10" alt="" title=""/>
         <xsl:text>&#160;</xsl:text>
         <a href="gpl_de.html">
          <xsl:value-of select="normalize-space(/chapter/license)"/>
         </a>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="normalize-space(/chapter/license)"/>
        </xsl:otherwise>
       </xsl:choose>
      </td>
     </tr>
    </table>
   </td>
  </tr>
 </xsl:template>

 <!--
  Benannte Vorlage zur Ausgabe der Autoren/Layouter
 -->

  <xsl:template name="do_author">
   <table width="100%">
    <tr>
     <td width="50%" align="top">

      <a name="author"/>
      <xsl:choose>
       <xsl:when test="count(/chapter/author) = 1">
        <h4>
         <xsl:text>Autor</xsl:text>
        </h4>
       </xsl:when>
       <xsl:otherwise>
        <h4>
         <xsl:text>Autoren</xsl:text>
        </h4>
       </xsl:otherwise>
      </xsl:choose>

      <ul>
       <xsl:for-each select="/chapter/author">
        <li>
         <em>
          <xsl:value-of select="normalize-space(name)"/>
         </em>
         <xsl:if test="mailto">
          <br/>
          <img src="../bilder/email.png" width="16" height="10" alt="" title=""/>
          <xsl:text>&#160;</xsl:text>
          <a>
           <xsl:attribute name="href">mailto:<xsl:value-of select="normalize-space(mailto)"/></xsl:attribute>
           <xsl:value-of select="normalize-space(mailto)"/>
          </a>
         </xsl:if>
        </li>
       </xsl:for-each>
      </ul>

     </td>
     <td width="50%" valign="top">

      <a name="layout"/>
      <h4>
       <xsl:text>Formatierung</xsl:text>
      </h4>

      <ul>
       <xsl:for-each select="/chapter/layout">
        <li>
         <em>
          <xsl:value-of select="normalize-space(name)"/>
         </em>
         <xsl:if test="mailto">
          <br/>
          <img src="../bilder/email.png" width="16" height="10" alt="" title=""/>
          <xsl:text>&#160;</xsl:text>
          <a>
           <xsl:attribute name="href">mailto:<xsl:value-of select="normalize-space(mailto)"/></xsl:attribute>
           <xsl:value-of select="normalize-space(mailto)"/>
          </a>
         </xsl:if>
        </li>
       </xsl:for-each>
      </ul>
     </td>
    </tr>
   </table>
  </xsl:template>

 <!--
  Benannte Vorlage zur Ausgabe der Fusszeile einer Seite
 -->
 
 <xsl:template name="do_footer">
  <br/>
  <table width="95%" align="center">
   <tr>
    <td colspan="2" bgcolor="#c9d8e5">
     <table width="100%">
      <xsl:call-template name="do_prevnext">
       <xsl:with-param name="pos">down</xsl:with-param>
      </xsl:call-template>
     </table>
    </td>
   </tr>
  </table>
 </xsl:template>

 <!--
  Benannte Vorlage zur Ausgabe der Navigationselemente (weiter u. zurueck)
 -->

 <xsl:template name="do_prevnext">
  <xsl:param name="pos"/>
   <xsl:choose>

    <!-- Mini-Dokumente brauchen Sonderbehandlung, sonst funktionieren die vor/zurück-Links nicht -->
    <xsl:when test="count(//split//section)=1">
     <td align="left">
      <xsl:call-template name="prevdok" />
     </td>
     <td align="center" width="100%">
      <xsl:call-template name="nav_center">
       <xsl:with-param name="pos" select="$pos"/>
       <xsl:with-param name="split">0</xsl:with-param>
      </xsl:call-template>
     </td>
    
     <td align="right">
      <xsl:call-template name="nextdok" />
     </td>
    </xsl:when>
   
    <xsl:when test="self::split">
     <tr>
      <td align="left">
       <xsl:choose>
        <xsl:when test="position() != 1">
         <a>
          <xsl:attribute name="href">
           <xsl:value-of select="normalize-space(/chapter/index)"/>
           <xsl:number format="01" value="position()-1"/>
           <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <img border="0" width="24" height="24" alt="zurück" title="zurück">
           <xsl:attribute name="src">
            <xsl:value-of select="$img_dir"/>
            <xsl:text>/links.png</xsl:text>
           </xsl:attribute>
          </img>
         </a>
        </xsl:when>
        <xsl:otherwise>
         <a>
          <xsl:attribute name="href">
           <xsl:value-of select="normalize-space(/chapter/index)"/>
           <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <img border="0" width="24" height="24" alt="zurück" title="zurück">
           <xsl:attribute name="src">
            <xsl:value-of select="$img_dir"/>
            <xsl:text>/links.png</xsl:text>
           </xsl:attribute>
          </img>
         </a>
        </xsl:otherwise>
       </xsl:choose>
      </td>
      
      <td align="center" width="100%">
       <xsl:call-template name="nav_center">
        <xsl:with-param name="pos" select="$pos" />
        <xsl:with-param name="split">1</xsl:with-param>
       </xsl:call-template>
      </td>
     
      <td align="right">
       <xsl:choose>
        <xsl:when test="position() != last()">
         <a>
          <xsl:attribute name="href">
           <xsl:value-of select="normalize-space(/chapter/index)"/>
           <xsl:number format="01" value="position()+1"/>
           <xsl:text>.html</xsl:text>
          </xsl:attribute>
          <img border="0" width="24" height="24" alt="weiter" title="weiter">
           <xsl:attribute name="src">
            <xsl:value-of select="$img_dir"/>
            <xsl:text>/rechts.png</xsl:text>
           </xsl:attribute>
          </img>
         </a>
        </xsl:when>
        <xsl:otherwise>
         <xsl:call-template name="nextdok" />
        </xsl:otherwise>
       </xsl:choose>
      </td>
     </tr>
    </xsl:when>
    <xsl:otherwise>
     <tr>
     
      <td align="left">
       <xsl:call-template name="prevdok" />
      </td>
      
      <td align="center" width="100%">
       <xsl:call-template name="nav_center">
        <xsl:with-param name="pos" select="$pos"/>
        <xsl:with-param name="split">0</xsl:with-param>
       </xsl:call-template>
      </td>
     
      <td align="right">
      <a>
       <xsl:attribute name="href">
        <xsl:value-of select="normalize-space(/chapter/index)"/>
        <xsl:text>01.html</xsl:text>
       </xsl:attribute>
       <img border="0" width="24" height="24" alt="weiter" title="weiter">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/rechts.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </td>
    </tr>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  nav_center - erzeugt die Navigationselemente in der Mitte der Navigationszeile 
  'pos' gibt die Position der Navigationszeile (up,down) an,
  'split' gibt an, ob die Zeile auf einer Übersichtsseite (0) oder in einem Split (1) auftaucht
 -->

 <xsl:template name="nav_center">
  <xsl:param name="pos"/>
  <xsl:param name="split">0</xsl:param>
  
  <xsl:choose>
   <xsl:when test="$split = 1">
   
    <xsl:choose>
     <xsl:when test="$pos = 'down'">
      <a href="#top">
       <img border="0" width="24" height="24" alt="Seitenanfang" title="Seitenanfang">
        <xsl:attribute name="src">
         <xsl:text>../bilder/top.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
      <xsl:text>&#160;</xsl:text>
     </xsl:when>
    </xsl:choose>
    
    <a href="../index.html">
     <img border="0" width="24" height="24" alt="Startseite" title="Startseite">
      <xsl:attribute name="src">
       <xsl:text>../bilder/start.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
    
    <xsl:text>&#160;</xsl:text>
    
    <a>
     <xsl:attribute name="href">
      <xsl:value-of select="normalize-space(/chapter/index)"/>
      <xsl:text>.html</xsl:text>
     </xsl:attribute>
     <img border="0" width="24" height="24" alt="Kapitelanfang" title="Kapitelanfang">
      <xsl:attribute name="src">
       <xsl:text>../bilder/kapitel.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
    
    <xsl:text>&#160;</xsl:text>
    
    <a href="inhalt.html">
     <img border="0" width="24" height="24" alt="Inhaltsverzeichnis" title="Inhaltsverzeichnis">
      <xsl:attribute name="src">
       <xsl:text>../bilder/inhalt.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
    
    <xsl:choose>
     <xsl:when test="$variant = 'online'">
      <xsl:text>&#160;</xsl:text>
      <a>
       <xsl:attribute name="href">
        <xsl:text>../pdf/</xsl:text>
        <xsl:value-of select="normalize-space(/chapter/index)"/>
        <xsl:text>.pdf</xsl:text>
       </xsl:attribute>
       <img border="0" width="24" height="24">
        <xsl:attribute name="src">
         <xsl:text>../bilder/druckversion.png</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:text>PDF-Download (</xsl:text>
         <xsl:value-of select="$pdfsize"/>
         <xsl:text>)</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:text>PDF-Download (</xsl:text>
         <xsl:value-of select="$pdfsize"/>
         <xsl:text>)</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when>
    </xsl:choose>
    
    <xsl:choose>
     <xsl:when test="normalize-space(/chapter/license) = 'GFDL'">
      <xsl:text>&#160;</xsl:text>
      <a href="gfdl_de.html">
       <img src="../bilder/gfdl.png" border="0" width="24" height="24" alt="GFDL" title="GFDL"/>
      </a>
     </xsl:when>
     <xsl:when test="normalize-space(/chapter/license) = 'GPL'">
      <xsl:text>&#160;</xsl:text>
      <a href="gpl_de.html">
       <img src="../bilder/gpl.png" border="0" width="24" height="24" alt="GPL" title="GPL"/>
      </a>
     </xsl:when>
    </xsl:choose>
   </xsl:when>
   
   <xsl:otherwise>
   
    <xsl:choose>
     <xsl:when test="$pos = 'down'">
      <a href="#top">
       <img border="0" width="24" height="24" alt="Seitenanfang" title="Seitenanfang">
        <xsl:attribute name="src">
         <xsl:text>../bilder/top.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
      <xsl:text>&#160;</xsl:text>
     </xsl:when>
    </xsl:choose>
    
    <a href="../index.html">
     <img border="0" width="24" height="24" alt="Startseite" title="Startseite">
      <xsl:attribute name="src">
       <xsl:text>../bilder/start.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
    
    <xsl:text>&#160;</xsl:text>
    
    <a href="inhalt.html">
     <img border="0" width="24" height="24" alt="Inhaltsverzeichnis" title="Inhaltsverzeichnis">
      <xsl:attribute name="src">
       <xsl:text>../bilder/inhalt.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
    
    <xsl:choose>
     <xsl:when test="$variant = 'online'">
      <xsl:text>&#160;</xsl:text>
      <a>
       <xsl:attribute name="href">
        <xsl:text>../pdf/</xsl:text>
        <xsl:value-of select="normalize-space(/chapter/index)"/>
        <xsl:text>.pdf</xsl:text>
       </xsl:attribute>
       <img border="0" width="24" height="24">
        <xsl:attribute name="src">
         <xsl:text>../bilder/druckversion.png</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:text>PDF-Download (</xsl:text>
         <xsl:value-of select="$pdfsize"/>
         <xsl:text>)</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:text>PDF-Download (</xsl:text>
         <xsl:value-of select="$pdfsize"/>
         <xsl:text>)</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when>
    </xsl:choose>
    
    <xsl:choose>
     <xsl:when test="normalize-space(/chapter/license) = 'GFDL'">
      <xsl:text>&#160;</xsl:text>
      <a href="gfdl_de.html">
       <img src="../bilder/gfdl.png" border="0" width="24" height="24" alt="GFDL" title="GFDL"/>
      </a>
     </xsl:when>
     <xsl:when test="normalize-space(/chapter/license) = 'GPL'">
      <xsl:text>&#160;</xsl:text>
      <a href="gpl_de.html">
       <img src="../bilder/gpl.png" border="0" width="24" height="24" alt="GPL" title="GPL"/>
      </a>
     </xsl:when>
    </xsl:choose>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  prevdok - erzeugt einen Link auf die letzte Seite des vorherigen Dokuments
 -->
 
 <xsl:template name="prevdok">
  <xsl:if test="$index != 'none'">
   <xsl:choose>
    <xsl:when test="document($index)//chapter[@index=$chapter_index]/preceding-sibling::*[self::directory or self::chapter]">
     <xsl:apply-templates select="document($index)//chapter[@index=$chapter_index]/preceding-sibling::*[self::directory or self::chapter][1]/descendant-or-self::*[self::directory or self::chapter][last()]" mode="prevnext">
      <xsl:with-param name="type">prev</xsl:with-param>
     </xsl:apply-templates>
    </xsl:when>
    <xsl:otherwise>
     <xsl:apply-templates select="document($index)//chapter[@index=$chapter_index]/ancestor::*[self::directory or self::selflinux][1]" mode="prevnext">
      <xsl:with-param name="type">prev</xsl:with-param>
     </xsl:apply-templates>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <!--
  nextdok - erzeugt einen Link auf die erste Seite des nächsten Dokuments
 -->
 
 <xsl:template name="nextdok">
  <xsl:if test="$index != 'none'">
   <xsl:if test="document($index)//chapter[@index=$chapter_index]/following::*[self::directory or self::chapter]">
    <xsl:apply-templates select="(document($index)//chapter[@index=$chapter_index]/following::*[self::directory or self::chapter])[1]" mode="prevnext">
     <xsl:with-param name="type">next</xsl:with-param>
    </xsl:apply-templates>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="directory|chapter|selflinux" mode="prevnext">
  <xsl:param name="type"/>
  <xsl:param name="prefix"/>
  
  <xsl:choose>
   <xsl:when test="self::directory">
   
   <xsl:choose>
    <xsl:when test="$type = 'next'">
     <a>
      <xsl:attribute name="href">
       <xsl:value-of select="$prefix"/>
       <xsl:value-of select="@file"/>
       <xsl:text>.html</xsl:text>
      </xsl:attribute>
      <img border="0" width="24" height="24">
       <xsl:attribute name="src">
        <xsl:value-of select="$img_dir"/>
        <xsl:text>/rechts.png</xsl:text>
       </xsl:attribute>
       <xsl:attribute name="alt">
        <xsl:value-of select="@title"/>
       </xsl:attribute>
       <xsl:attribute name="title">
        <xsl:value-of select="@title"/>
       </xsl:attribute>
      </img>
     </a>
    </xsl:when>
    <xsl:otherwise>
     <a>
      <xsl:attribute name="href">
       <xsl:value-of select="$prefix"/>
       <xsl:value-of select="@file"/>
       <xsl:text>.html</xsl:text>
      </xsl:attribute>
      <img border="0" width="24" height="24">
       <xsl:attribute name="src">
        <xsl:value-of select="$img_dir"/>
        <xsl:text>/links.png</xsl:text>
       </xsl:attribute>
       <xsl:attribute name="alt">
        <xsl:value-of select="@title"/>
       </xsl:attribute>
       <xsl:attribute name="title">
        <xsl:value-of select="@title"/>
       </xsl:attribute>
      </img>
     </a>
    </xsl:otherwise>
   </xsl:choose>
   
  </xsl:when>
  <xsl:when test="self::selflinux">
  
   <a href="../index.html">
    <img border="0" width="24" height="24" alt="SelfLinux" title="SelfLinux">
     <xsl:attribute name="src">
      <xsl:value-of select="$img_dir"/>
      <xsl:text>/links.png</xsl:text>
     </xsl:attribute>
    </img>
   </a>
   
   </xsl:when>
   <xsl:otherwise>
  
    <xsl:choose>
     <xsl:when test="$type = 'next'">
      <a>
       <xsl:attribute name="href">
        <xsl:value-of select="$prefix"/>
        <xsl:value-of select="@index"/>
        <xsl:text>.html</xsl:text>
       </xsl:attribute>
       <img border="0" width="24" height="24">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
        <xsl:text>/rechts.png</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:value-of select="title"/>
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:value-of select="title"/>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when>
     <xsl:otherwise>
      <a>
       <xsl:attribute name="href">
        <xsl:value-of select="$prefix"/>
        <xsl:value-of select="@index"/>
       
        <!-- Mini-Dokumente haben keine Splits -->
        <xsl:if test="not(@minichapter)">
         <xsl:value-of select="section[last()]/@split"/>
        </xsl:if>
       
        <xsl:text>.html</xsl:text>
       </xsl:attribute>
       <img border="0" width="24" height="24">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/links.png</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:value-of select="title"/>
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:value-of select="title"/>
        </xsl:attribute>
       </img>
      </a>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
