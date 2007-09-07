<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * dirs.xsl - Produziert das Verzeichnis der SelfLinux-Dokumente
 * Copyright Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.37 $
 * $Source: /selflinux/stylesheets/html/dirs.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: dirs.xsl,v 1.37 2004/05/25 20:54:47 florian Exp $
-->

<xsl:stylesheet version="1.1"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon">

 <!-- 
  Dieses XSLT konvertiert den erweiterten Index in die HTML-Übersichtsseiten
  und das Inhaltsverzeichnis.

  Bedeutung der Parameter:
  html_dir  Pfad zum Ausgabeverzeichnis der HTML-Dokumente
  variant   muss auf "online" gesetzt werden, um die online-Variante zu erzeugen
  version   Die SelfLinux-Version, die erzeugt werden soll
  silent    wird nicht verwendet
  index     muss den Namen desselben Index-Dokuments-enthalten, das durch
            dieses XSLT gejagt wird. Dies ist nötig, damit format.xsl für
            main.xsl und dir.xsl verwendet werden kann (ansonsten
            funktionieren die irefs nicht)

  Ausgaben:
  Auf der Standardausgabe wird die SelfLinux-Startseite ausgegeben. Im
  Verzeichnis $html_dir werden alle untergeordneten Seiten abgelegt.

  Es wird folgende Verzeichnisstruktur erwartet:
  /foo/bar/index.html   <- SelfLinux-Startseite
  /foo/bar/html/        <- html_dir
 -->

 <!-- Variablen definieren -->
 <xsl:param name="html_dir">.</xsl:param>
 <xsl:param name="variant">.</xsl:param>
 <xsl:param name="version">.</xsl:param>
 <xsl:param name="silent">false</xsl:param>

 <xsl:param name="index">none</xsl:param>

 <!-- Externe Vorlagen einbinden -->
 <xsl:include href="format.xsl"/>

 <xsl:output method="html" indent="yes" encoding="ISO-8859-1"/>

 <!--
  Haupt-Template 
  Die Ausgaben werden in 3 Schritten erzeugt:
  - alle Unterverzeichnisse
  - Startseite
  - Inhaltsverzeichnis
 -->
 
 <xsl:template match="/">
  <xsl:apply-templates select="//directory"/>
  <xsl:apply-templates select="selflinux"/>
  <xsl:call-template name="inhalt"/>
 </xsl:template>

 <!--
  SelfLinux-Template
  Gibt die SL-Startseite auf die Standardausgabe aus. 

  Da die Startseite und die Unterverzeichnisseiten gleich aussehen, wird für
  beides make_page aufgerufen. Einziger Unterschied zwischen Startseite und
  Unterverzeichnissen: andere Pfade für Bilder und Html-Seiten.
 -->
 
 <xsl:template match="selflinux">
  <xsl:call-template name="make_page">
   <xsl:with-param name="img_dir">bilder</xsl:with-param>
   <xsl:with-param name="html_dir">html/</xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <!--
  Directory-Template
  Erzeugt eine Unterverzeichnisseite und speichert sie im $html_dir ab.

  Der Dateiname ergibt sich aus dem @file-Attribut, die eigentliche Seite wird
  von make_page erstellt.
 -->
 
 <xsl:template match="directory">
  <xsl:variable name="html_file">
   <xsl:value-of select="@file"/>
  </xsl:variable>
  <xsl:document method="html"
   href="{$html_dir}/{$html_file}.html"
   encoding="iso-8859-1"
   indent="yes">
   <xsl:call-template name="make_page">
    <xsl:with-param name="img_dir">../bilder</xsl:with-param>
   </xsl:call-template>
  </xsl:document>
 </xsl:template>

 <!--
  Inhalt-Template
  Erstellt das Inhaltsverzeichnis und speichert es unter $html_dir/inhalt.html.

  Auch hierfür wird make_page aufgerufen.
 -->

 <xsl:template name="inhalt">
  <xsl:document method="html"
   href="{$html_dir}/inhalt.html"
   encoding="iso-8859-1"
   indent="yes">
   <xsl:call-template name="make_page">
    <xsl:with-param name="img_dir">../bilder</xsl:with-param>
    <xsl:with-param name="modus">inhalt</xsl:with-param>
   </xsl:call-template>
  </xsl:document>
 </xsl:template>

 <!--
  make-page-template
  Gemeinsames Template für die Erstellung von Startseite,
  Unterverzeichnisseiten und Inhaltsverzeichnis.

  Der Grundsätzliche Aufbau der Ausgabe: Innerhalb des SL-Rahmens kommt
  zunächst eine Beschreibung (description-Tag des Verzeichnisses, entfällt
  beim Inhaltsverzeichnis), danach folgt die Auflistung der Verzeichnisse und
  Dokumente.

  Die Parameter steuern die Funktionsweise:
  img_dir    relativer Pfad zu den Bilddateien
  html_dir   relativer Pfad zu den html-Dateien

  modus      "normal" für die Übersichtsseiten,
             "index" für das Inhaltsverzeichnis

  Für die Erstellung des Seitenrahmens werden die Templates do_copyright,
  do_headline, do_header, do_footer genutzt.

  Zur Erstellung des Inhaltsverzeichnisses dient der index-Modus, die anderen
  Seiten werden von do_dir erstellt.
 -->
 
 <xsl:template name="make_page">
  <xsl:param name="img_dir"/>
  <xsl:param name="html_dir"/>
  <xsl:param name="modus">normal</xsl:param>
  <xsl:text disable-output-escaping="yes">
   <![CDATA[
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
   ]]>
  </xsl:text>
  
  <html>

   <xsl:call-template name="do_copyright"/>
   <head>
    <xsl:choose>
     <xsl:when test="@title">
      <title>SelfLinux - <xsl:value-of select="@title"/></title>
     </xsl:when>
     <xsl:when test="$modus = 'inhalt'">
      <title>SelfLinux - Inhaltsverzeichnis</title>
     </xsl:when>
     <xsl:otherwise>
      <title>SelfLinux</title>
     </xsl:otherwise>
    </xsl:choose>
   </head>
   
   <body bgcolor="#FFFFFF">
    <xsl:call-template name="do_headline">
     <xsl:with-param name="modus" select="$modus"/>
    </xsl:call-template>

    <!-- Seitenrahmen -->
    <table width="95%" align="center" cellspacing="0" cellpadding="5">
     <xsl:call-template name="do_header">
      <xsl:with-param name="img_dir" select="$img_dir"/>
      <xsl:with-param name="modus" select="$modus"/>
     </xsl:call-template>

     <xsl:choose>
      <xsl:when test="$modus = 'inhalt'">
       <tr>
        <td valign="top">
         <xsl:text>&#160;</xsl:text>
        </td>
        <td colspan="2">
         <br/>
         <xsl:apply-templates select="/selflinux/directory|chapter" mode="inhalt">
          <xsl:with-param name="html_dir" select="$html_dir"/>
          <xsl:with-param name="img_dir" select="$img_dir"/>
         </xsl:apply-templates>
        </td>
       </tr>
      </xsl:when>
      <xsl:otherwise>
       <xsl:call-template name="do_dir">
        <xsl:with-param name="img_dir" select="$img_dir"/>
        <xsl:with-param name="html_dir" select="$html_dir"/>
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </table>

    <xsl:call-template name="do_footer">
     <xsl:with-param name="html_dir" select="$html_dir"/>
     <xsl:with-param name="modus" select="$modus"/>
    </xsl:call-template>

   </body>
  </html>

 </xsl:template>

 <!-- 
  ***************************
  * Templates für make_page *
  ***************************

  Es folgen die von make_page genutzten Templates.
 -->

 <!-- do_dir-Template
  Erzeugt eine Verzeichnisseite. 

  Zunächst wird der Inhalt des Description-Tags ausgegeben (wenn Textblöcke
  enthalten sind, werden diese geparsed)
  Danach folgt die Auflistung aller Unterverzeichnisse und Kapitel.
 -->
 
 <xsl:template name="do_dir">
  <xsl:param name="img_dir"/>
  <xsl:param name="html_dir"/>
  <tr>
   <td valign="top">
    <xsl:text>&#160;</xsl:text>
   </td>
   <td colspan="2">
    <br/>
    <xsl:choose>
     <xsl:when test="description/textblock">
      <xsl:apply-templates select="description"/>
     </xsl:when>
     <xsl:when test="description">
      <p>
       <xsl:apply-templates select="description"/>
      </p>
     </xsl:when>
    </xsl:choose>
    <xsl:for-each select="directory|chapter">
     <xsl:choose>
      <xsl:when test="self::directory">
       <a>
        <xsl:attribute name="href">
         <xsl:value-of select="$html_dir"/>
         <xsl:value-of select="@file"/>
         <xsl:text>.html</xsl:text>
        </xsl:attribute>
        <img border="0" width="23" height="17" alt="DIR">
         <xsl:attribute name="src">
          <xsl:value-of select="$img_dir"/>
          <xsl:text>/img_folder.png</xsl:text>
         </xsl:attribute>
        </img>
       </a>
       <xsl:text>&#160;</xsl:text>
       <a>
        <xsl:attribute name="href">
         <xsl:value-of select="$html_dir"/>
         <xsl:value-of select="@file"/>
         <xsl:text>.html</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="@title"/>
       </a>
      </xsl:when>
      <xsl:otherwise>
       <a>
        <xsl:attribute name="href">
         <xsl:value-of select="$html_dir"/>
         <xsl:value-of select="@index"/>
         <xsl:text>.html</xsl:text>
        </xsl:attribute>
        <img border="0" width="18" height="22" alt="Dokument">
         <xsl:attribute name="src">
          <xsl:value-of select="$img_dir"/>
          <xsl:text>/img_document.png</xsl:text>
         </xsl:attribute>
        </img>
       </a>
       <xsl:text>&#160;</xsl:text>
       <a>
        <xsl:attribute name="href">
         <xsl:value-of select="$html_dir"/>
         <xsl:value-of select="@index"/>
         <xsl:text>.html</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(title)"/>
       </a>
       <img width="1" height="8" alt="" title="">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/img_transparent.png</xsl:text>
        </xsl:attribute>
       </img>
      </xsl:otherwise>
     </xsl:choose>
     <br/>
     <img width="1" height="8" alt="" title="">
      <xsl:attribute name="src">
       <xsl:value-of select="$img_dir"/>
       <xsl:text>/img_transparent.png</xsl:text>
      </xsl:attribute>
     </img>
     <br/>
    </xsl:for-each>
   </td>
  </tr>
 </xsl:template>

 <!--
  directory-Template für Inhaltsverzeichnis
  Erzeugt den Eintrag für ein Directory im Inhaltsverzeichnis.

  Zunächst wird der Eintrag je nach Schachtelungstiefe eingerückt. 
  Es folgt der übliche Eintrag für ein Verzeichnis.
  Danach werden alle Unterverzeichnisse und enthaltene Kapitel bearbeitet.
 -->
 
 <xsl:template match="directory" mode="inhalt">
  <xsl:param name="html_dir"/>
  <xsl:param name="img_dir"/>

  <xsl:for-each select="ancestor::directory">
   <img border="0" width="25" height="20" alt="" title="">
    <xsl:attribute name="src">
     <xsl:value-of select="$img_dir"/>
     <xsl:text>/img_transparent.png</xsl:text>
    </xsl:attribute>
   </img>
  </xsl:for-each>
  <a>
   <xsl:attribute name="href">
    <xsl:value-of select="$html_dir"/>
    <xsl:value-of select="@file"/>
    <xsl:text>.html</xsl:text>
   </xsl:attribute>
   <img border="0" width="23" height="17" alt="DIR">
    <xsl:attribute name="src">
     <xsl:value-of select="$img_dir"/>
     <xsl:text>/img_folder.png</xsl:text>
    </xsl:attribute>
   </img>
  </a>
  <xsl:text>&#160;</xsl:text>
  <a>
   <xsl:attribute name="href">
    <xsl:value-of select="$html_dir"/>
    <xsl:value-of select="@file"/>
    <xsl:text>.html</xsl:text>
   </xsl:attribute>
   <xsl:value-of select="@title"/>
  </a>
  <br/>
  <img width="1" height="8" alt="" title="">
   <xsl:attribute name="src">
    <xsl:value-of select="$img_dir"/>
    <xsl:text>/img_transparent.png</xsl:text>
   </xsl:attribute>
  </img>
  <br/>
  <xsl:apply-templates select="directory|chapter" mode="inhalt">
   <xsl:with-param name="html_dir" select="$html_dir"/>
   <xsl:with-param name="img_dir" select="$img_dir"/>
  </xsl:apply-templates>
 </xsl:template>

 <!--
  chapter-Template für Inhaltsverzeichnis
  Erzeugt den Eintrag für ein Kapitel im Inhaltsverzeichnis.

  Zunächst wird der Eintrag nach Schachtelungstiefe eingerückt.
  Danach folgt der Kapiteleintrag, wie gewohnt mit Bild und Name.
 -->
 
 <xsl:template match="chapter" mode="inhalt">
  <xsl:param name="html_dir"/>
  <xsl:param name="img_dir"/>

  <xsl:for-each select="ancestor::directory">
   <img border="0" width="25" height="20" alt="" title="">
    <xsl:attribute name="src">
     <xsl:value-of select="$img_dir"/>
     <xsl:text>/img_transparent.png</xsl:text>
    </xsl:attribute>
   </img>
  </xsl:for-each>
  <a>
   <xsl:attribute name="href">
    <xsl:value-of select="$html_dir"/>
    <xsl:value-of select="@index"/>
    <xsl:text>.html</xsl:text>
   </xsl:attribute>
   <img border="0" width="18" height="22" alt="Dokument">
    <xsl:attribute name="src">
     <xsl:value-of select="$img_dir"/>
     <xsl:text>/img_document.png</xsl:text>
    </xsl:attribute>
   </img>
  </a>
  <xsl:text>&#160;</xsl:text>
  <a>
   <xsl:attribute name="href">
    <xsl:value-of select="$html_dir"/>
    <xsl:value-of select="@index"/>
    <xsl:text>.html</xsl:text>
   </xsl:attribute>
   <xsl:value-of select="normalize-space(title)"/>
  </a>
  <br/>
  <img width="1" height="8" alt="" title="">
   <xsl:attribute name="src">
    <xsl:value-of select="$img_dir"/>
    <xsl:text>/img_transparent.png</xsl:text>
   </xsl:attribute>
  </img>
  <br/>
 </xsl:template>

 <!--
  *************************
  * Bibliotheksfunktionen *
  *************************

  Es folgen die Hilfsfunktionen für alle obigen Templates.

  vgl. auch keyword.xsl, lib.xsl
 -->

 <!--
  do_copyright-Template
  Gibt den HTML-Kommentar mit der Copyright-Notiz aus.
 -->
 
 <xsl:template name="do_copyright">
  <xsl:comment>
 * SelfLinux - Übersichtsseite
 * Copyright SelfLinux-Team
 *
 * <xsl:value-of select="normalize-space(/selflinux/cvs/name)"/>
 * <xsl:value-of select="normalize-space(/selflinux/cvs/revision)"/>
 * <xsl:value-of select="normalize-space(/selflinux/cvs/source)"/>
 * <xsl:value-of select="$version"/>
 *
 * Diese Datei ist Teil von SelfLinux http://www.selflinux.de
 *
 *** <xsl:value-of select="normalize-space(/selflinux/cvs/id)"/>
  </xsl:comment>
 </xsl:template>

 <!--
  dir_path-Template
  Erzeugt die "Pfadangabe" des Verzeichnisses. Wie bei den Dokuenten sind 
  alle Pfadelemente bis auf den letzten Links auf die jeweiligen Seiten.
 -->
 
 <xsl:template name="dir_path">
  <xsl:choose>
   <xsl:when test="self::selflinux">
    <img src="bilder/pfadpfeil.png" alt="&#187;" title=""/>
    <xsl:text>&#160;</xsl:text>
    <xsl:text>SelfLinux</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
    <xsl:text>&#160;</xsl:text>
    <a href="../index.html">SelfLinux</a>
    <xsl:variable name="filename"><xsl:value-of select="@file"/></xsl:variable>
    <xsl:for-each select="//directory[descendant-or-self::directory[@file = $filename]]">
     <xsl:text>&#160;</xsl:text>
     <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
     <xsl:text>&#160;</xsl:text>
     <xsl:choose>
      <xsl:when test="position() = last()">
       <xsl:value-of select="normalize-space(@title)"/>
      </xsl:when>
      <xsl:otherwise>
       <a>
        <xsl:attribute name="href">
         <xsl:value-of select="@file"/>
         <xsl:text>.html</xsl:text>
        </xsl:attribute>
        <xsl:value-of select="normalize-space(@title)"/>
       </a>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  do_headline-Template
  Erzeugt die Kopfzeile (Pfadangabe, Versionsbezeichnung und der dünne
  dunklere Balken).
 -->
 
<xsl:template name="do_headline">
 <xsl:param name="modus"/>
  <table width="95%" align="center">
   <tr>
    <td align="left">
     <xsl:call-template name="dir_path"/>
     <xsl:if test="$modus = 'inhalt'">
      <xsl:text>&#160;</xsl:text>
      <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
      <xsl:text>&#160;</xsl:text>
      <xsl:text>Inhaltsverzeichnis</xsl:text>
     </xsl:if>
    </td>
    <td align="right">
     <xsl:value-of select="$version"/>
    </td>
   </tr>
   <tr>
    <td bgcolor="#c9d8e5" colspan="2">
     <table width="100%">
      <xsl:call-template name="do_prevnext">
       <xsl:with-param name="modus" select="$modus"/>
       <xsl:with-param name="pos">top</xsl:with-param>
      </xsl:call-template>
     </table>
    </td>
   </tr>
  </table>
  <br/>
 </xsl:template>

 <!--
  do_header-Template
  Erzeugt den Dokumentenheader (hellerer Balken mit SelfLinux-Logo und 
  dem Namen des aktuellen Dokuments)
 -->
 
 <xsl:template name="do_header">
  <xsl:param name="img_dir"/>
  <xsl:param name="modus"/>
  
  <tr>
   <td width="120">
    <img width="112" height="124" alt="SelfLinux-Logo">
     <xsl:attribute name="src">
     <xsl:value-of select="$img_dir"/>/selflinux.png</xsl:attribute>
    </img>
   </td>
   <td colspan="2" align="left" valign="middle" bgcolor="#f5f5f5" width="100%">
    <table width="100%">
     <tr>
      <td width="45">
       <img width="45" height="37" alt="Ordner" hspace="20" align="middle">
        <xsl:attribute name="src">
        <xsl:value-of select="$img_dir"/>/openfolder.png</xsl:attribute>
       </img>
      </td>
      <td align="left">
       <font size="+1">
        <xsl:choose>
         <xsl:when test="self::selflinux">
          <xsl:text>SelfLinux</xsl:text>
         </xsl:when>
         <xsl:when test="$modus = 'inhalt'">
          <xsl:text>Inhaltsverzeichnis</xsl:text>
         </xsl:when>
         <xsl:otherwise>
          <xsl:value-of select="@title"/>
         </xsl:otherwise>
        </xsl:choose>
       </font>
      </td>
     </tr>
    </table>
   </td>
  </tr>
 </xsl:template>

 <!--
  do_footer-Template
  Erzeugt die Fußzeile (farbiger Balken am Ende des Dokuments).
 -->
 
 <xsl:template name="do_footer">
  <xsl:param name="html_dir"/>
  <xsl:param name="modus"/>
  
  <br/>
  <table width="95%" align="center">
   <tr>
    <td colspan="2" bgcolor="#c9d8e5">
     <table width="100%">
      <xsl:call-template name="do_prevnext">
       <xsl:with-param name="modus" select="$modus"/>
       <xsl:with-param name="pos">down</xsl:with-param>
      </xsl:call-template>
     </table>
    </td>
   </tr>
  </table>
 </xsl:template>

 <!--
  do_prevnext-Template
  Erzeugt die Navigationszeile (mit den Pfeilen für Vor/Zurück), die in Kopf-
  und Fußzeile eingefügt wird.

  Der Parameter pos gibt an, ob die obere oder die undere Navigationszeile
  erzeugt wird, da der Link zum Dokumentenanfang nur unten eingefügt wird.
 -->
 
 <xsl:template name="do_prevnext">
  <xsl:param name="modus"/>
  <xsl:param name="pos"/>
  <xsl:variable name="prefix">
   <xsl:if test="self::selflinux">
    <xsl:text>html/</xsl:text>
   </xsl:if>
  </xsl:variable>
  <xsl:variable name="img_dir">
   <xsl:if test="not(self::selflinux)">
    <xsl:text>../</xsl:text>
   </xsl:if>
   <xsl:text>bilder/</xsl:text>
  </xsl:variable>
  
  <xsl:choose>
   <xsl:when test="$modus = 'inhalt'">
    <tr>
     <td align="left">
      <a href="../index.html">
       <img border="0" width="24" height="24" alt="SelfLinux" title="SelfLinux">
        <xsl:attribute name="src">
         <xsl:text>../bilder/links.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </td>
     <td align="center" width="100%">
      <xsl:choose>
       <xsl:when test="$pos = 'down'">
        <a href="inhalt.html">
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
     </td>
     <td align="right">
      <a href="../index.html">
       <img border="0" width="24" height="24" alt="SelfLinux" title="SelfLinux">
        <xsl:attribute name="src">
         <xsl:text>../bilder/rechts.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </td>
    </tr>
   </xsl:when>
   <xsl:otherwise>
    <tr>
     <td align="left">
      <xsl:choose>
       <xsl:when test="preceding-sibling::*[self::directory or self::chapter]">
        <xsl:apply-templates select="preceding-sibling::*[self::directory or self::chapter][1]/descendant-or-self::*[self::directory or self::chapter][last()]" mode="prevnext">
         <xsl:with-param name="type">prev</xsl:with-param>
         <xsl:with-param name="img_dir" select="$img_dir"/>
        </xsl:apply-templates>
       </xsl:when>
       <xsl:when test="ancestor::directory|ancestor::selflinux">
        <xsl:apply-templates select="(ancestor::selflinux|ancestor::directory)[last()]" mode="prevnext">
         <xsl:with-param name="type">prev</xsl:with-param>
         <xsl:with-param name="img_dir" select="$img_dir"/>
        </xsl:apply-templates>
       </xsl:when>
      </xsl:choose>
     </td>
     <td align="center" width="100%">
      <xsl:choose>
       <xsl:when test="ancestor::directory|ancestor::selflinux">
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
       </xsl:when>
       <xsl:when test="self::selflinux">
        <a href="html/inhalt.html">
         <img border="0" width="24" height="24" alt="Inhaltsverzeichnis" title="Inhaltsverzeichnis">
          <xsl:attribute name="src">
           <xsl:text>bilder/inhalt.png</xsl:text>
          </xsl:attribute>
         </img>
        </a>
       </xsl:when>
      </xsl:choose>
     </td>
     <td align="right">
      <xsl:choose>
       <xsl:when test="child::directory|chapter">
        <xsl:apply-templates select="(child::directory|child::chapter)[1]" mode="prevnext">
         <xsl:with-param name="type">next</xsl:with-param>
         <xsl:with-param name="img_dir" select="$img_dir"/>
         <xsl:with-param name="prefix">
          <xsl:value-of select="$prefix"/>
         </xsl:with-param>
        </xsl:apply-templates>
       </xsl:when>
       <xsl:when test="following::directory|following::chapter">
        <xsl:apply-templates select="(following::directory|following::chapter)[1]" mode="prevnext">
         <xsl:with-param name="type">next</xsl:with-param>
         <xsl:with-param name="img_dir" select="$img_dir"/>
        </xsl:apply-templates>
       </xsl:when>
      </xsl:choose>
     </td>
    </tr>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  prevnext-Template 
  Erzeugt die Vor-/Zurück-Links für die Navigationszeile.

  In do_prevnext wird mit einem komplexen XPath-Ausdruck das richtige 
  Element ermittelt und dann dieses Template aufgerufen, um den eigentlichen
  Link zu erzeugen.

  type gibt an, ob ein Link nach vorne (next) oder nach hinten (prev) gesetzt
  werden soll.
 -->
 
 <xsl:template match="directory|chapter|selflinux" mode="prevnext">
  <xsl:param name="type"/>
  <xsl:param name="prefix"/>
  <xsl:param name="img_dir">../bilder</xsl:param>
  
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

 <!--
  textblock-Template
  Wandelt textblöcke in der description von Verzeichnissen in html-Absätze.
 -->
 
 <xsl:template match="description/textblock">
  <p>
   <xsl:apply-templates/>
  </p>
 </xsl:template>

</xsl:stylesheet>
