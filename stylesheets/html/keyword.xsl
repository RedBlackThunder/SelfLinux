<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * keyword.xsl - Erzeugt das Stichwortverzeichnis der SelfLinux-Dokumente
 * Copyright Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.29 $
 * $Source: /selflinux/stylesheets/html/keyword.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.de
 *
 *** $Id: keyword.xsl,v 1.29 2004/04/02 10:57:32 jkolb Exp $
-->

<xsl:stylesheet version="1.1"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                extension-element-prefixes="saxon">

 <!-- Variablen definieren -->
 <xsl:param name="html_dir">.</xsl:param>
 <xsl:param name="variant">.</xsl:param>
 <xsl:param name="img_dir">../bilder</xsl:param>
 <xsl:param name="version">.</xsl:param>
 <xsl:param name="silent">false</xsl:param>
 <xsl:param name="debug">false</xsl:param>

 <!--
  Für keyword.xsl werden die gleichen Parameter wie für main.xsl benötigt:
  html_dir  Ausgabeverzeichnis
  variant   "online" für online-Variante
  version   SL-Versionsnummer
  silent    wird nicht verwendet
  debug     aktiviert den Debug-Modus (zusätzliche Seite mit allen Keywords wird
            erzeugt)
 -->


 <xsl:output method="html" indent="yes" encoding="ISO-8859-1"/>

 <!-- Haupt-Template 
  Mit Hilfe von make_page wird die Datei keyword.html gefüllt. Im Verlauf dieser
  Transformation werden auch die Unterseiten für die Buchstaben A-Z erzeugt.
  (in keyword-alphabet)

  Falls Debug-Modus aktiv wird auch noch die Debug-Seite erzeugt
 -->
 <xsl:template match="/">
  <xsl:document method="html" href="{$html_dir}/keyword.html"
                encoding="iso-8859-1"
                indent="yes">

   <xsl:call-template name="make_page"/>
  </xsl:document>
  <xsl:if test="$debug = 'true'">
   <xsl:document method="html" href="{$html_dir}/keyword-all.html"
                 encoding="iso-8859-1"
                 indent="yes">
    <xsl:call-template name="make_debugpage"/>
   </xsl:document>
  </xsl:if>
 </xsl:template>

 <!-- keyword-alphabet-Template
  Rekursives Template zum Ausgeben der Buchstabenliste für die Übersichtsseite.
  Gleichzeitig werden auch durch Aufruf von make_page die Seiten für den
  jeweiligen Buchstaben erzeugt.

  chars_remaining gibt an, welche Buchstaben noch durchlaufen werden müssen. Es
  werden immer die ersten 3 Zeichen beachtet. Das erste wird für den Link zum
  vorherigen, das zweite für den aktuellen Buchstaben, das dritte für den Link
  zum nächsten Buchstaben benötigt.

  Beim rekursiven Aufruf wird ein Zeichen gestrichen.
 -->
 <xsl:template name="keyword-alphabet">
  <xsl:param name="chars_remaining"> #ABCDEFGHIJKLMNOPQRSTUVWXYZ </xsl:param>
  <xsl:variable name="chars" select="substring($chars_remaining,1,3)"/>
  <xsl:variable name="char" select="substring($chars,2,1)"/>
  <xsl:variable name="urlchar">
   <xsl:choose>
    <xsl:when test="$char='#'">
     <xsl:text>-</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$char"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <td align="center" width="3%">
   <a>
    <xsl:attribute name="href">
     <xsl:text>keyword-</xsl:text>
     <xsl:value-of select="$urlchar"/>
     <xsl:text>.html</xsl:text>
    </xsl:attribute>
    <xsl:value-of select="$char"/>
   </a>
  </td>

  <xsl:document method="html" href="{$html_dir}/keyword-{$urlchar}.html"
                encoding="iso-8859-1"
                indent="yes">
   <xsl:call-template name="make_page">
    <xsl:with-param name="chars" select="$chars"/>
   </xsl:call-template>
  </xsl:document>

  <xsl:if test="string-length($chars_remaining) > 3">
   <xsl:call-template name="keyword-alphabet">
    <xsl:with-param name="chars_remaining" select="substring($chars_remaining,2)"/>
   </xsl:call-template>
  </xsl:if>
 </xsl:template>

 <!-- keyword-Template
  Erzeugt den Eintrag für ein Keyword. Der Eintrag wird nur erzeugt, wenn das
  Stichwort zum erstenmal auftaucht. Auch alle weiteren Vorkommen des Wortes
  werden bei diesem einen Aufruf bearbeitet.
 -->
 <xsl:template mode="keyword" match="keyword">
  <xsl:variable name="akt_word" select="text()"/>
  <xsl:if test="not(preceding::keyword[text() = $akt_word])">
   <tr>
    <td>
     <strong><xsl:value-of select="text()"/></strong>
    </td>
    <td>
     <xsl:for-each select=".|following::keyword[text() = $akt_word]">
      <xsl:if test="position() > 1">
       <xsl:text>, </xsl:text>	
      </xsl:if>
      <xsl:call-template name="keywordlink"/>
     </xsl:for-each>
    </td>
   </tr>
  </xsl:if>
 </xsl:template>

 <!-- keywordlink-Template
  Erzeugt einen Link auf den aktuellen Abschnitt, zur Verlinkung eines
  Stichworts. 
 -->
 <xsl:template mode="keyword" name="keywordlink">
  <a>
   <xsl:attribute name="href">
    <xsl:choose>
     <xsl:when test="ancestor::section">
      <xsl:value-of select="ancestor::chapter/@index"/>
      <xsl:if test="not(ancestor::chapter/@minichapter)">
       <xsl:value-of select="ancestor::*[self::textblock|self::section][1]/@split"/>
      </xsl:if>
      <xsl:text>.html#</xsl:text>
      <xsl:value-of select="ancestor::*[self::textblock|self::section][1]/@id"/>
     </xsl:when>
     <xsl:when test="ancestor::chapter">
      <xsl:value-of select="ancestor::chapter/@index"/>
      <xsl:text>.html</xsl:text>
     </xsl:when>
     <xsl:when test="ancestor::directory">
      <xsl:value-of select="ancestor::directory/@file"/>
      <xsl:text>.html</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <!-- Bitte Einrückung so lassen, da Meldung exakt wie hier ausgegeben wird (incl. Einrückung!)-->
      <xsl:message terminate="yes">
 <xsl:value-of select="saxon:systemId()"/>:<xsl:value-of select="saxon:line-number()"/>
 FEHLER: Keyword-Tag an falscher Stelle!
      </xsl:message>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute> <!-- href -->

   <xsl:choose>
    <xsl:when test="ancestor::chapter">
     <xsl:value-of select="ancestor::chapter/title"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="ancestor::directory/@title"/>
    </xsl:otherwise>
   </xsl:choose>
  </a>
 </xsl:template>


 <!-- make_page-Template
  Erzeugt die Html-Seite und den Seitenrahmen. Ist der Parameter chars gesetzt,
  so wird die Keyword-Seite für den angegebenen Buchstaben erzeugt. (Genauso wie
  oben werden 3 Buchstaben übergeben, der mittlere ist der aktuelle)

  Ist chars nicht gesetzt, so wird mit keyword-alphabet die Übersichtsseite
  erzeugt.
 -->
 <xsl:template name="make_page">
  <xsl:param name="img_dir">../bilder</xsl:param>
  <xsl:param name="chars"/>
  <html>

   <xsl:call-template name="do_copyright"/>
   <head>
    <title>
     <xsl:text>SelfLinux - Stichwortverzeichnis</xsl:text>
     <xsl:if test="$chars">
      <xsl:text> (</xsl:text>
      <xsl:value-of select="substring($chars,2,1)"/>
      <xsl:text>)</xsl:text>
     </xsl:if>
    </title>
   </head>

   <body bgcolor="#FFFFFF">
    <a name="top"/>
    <xsl:call-template name="do_headline">
     <xsl:with-param name="chars" select="$chars"/>
    </xsl:call-template>

    <!-- Seitenrahmen -->
    <table width="95%" align="center" cellspacing="0" cellpadding="5">
     <xsl:call-template name="do_header">
      <xsl:with-param name="img_dir" select="$img_dir"/>
      <xsl:with-param name="chars" select="$chars"/>
     </xsl:call-template>

     <tr>
      <td valign="top">
       <xsl:text>&#160;</xsl:text>
      </td>
      <td colspan="2">
       <xsl:choose>
        <xsl:when test="$chars">
         <table cellspacing="10">
          <xsl:choose>
           <xsl:when test="substring($chars,2,1)='#'">
            <!--
             Kleiner Trick: Alle bekannten Buchstaben durch A ersetzen und nur
             Keywords hernehmen, die mit einem Buchstaben != A beginnen Dadurch
             werden alle nicht-alphabet. Zeichen erwischt.
            -->
            <xsl:apply-templates mode="keyword" select="//keyword[translate(substring(text(),1,1),'abcdefghijklmnopqrstuvwxyzäöüABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜß','AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')!='A']">
             <xsl:sort order="ascending" data-type="text"/>
            </xsl:apply-templates>
           </xsl:when>
           <xsl:otherwise>
            <!--
             Groß- und Kleinbuchstaben sollen gleichbehandelt werden. äöüß zählt
             wie AOUS
            -->
            <xsl:apply-templates mode="keyword" select="//keyword[translate(substring(text(),1,1),'abcdefghijklmnopqrstuvwxyzäöüÄÖÜß','ABCDEFGHIJKLMNOPQRSTUVWXYZAOUAOUS')=substring($chars,2,1)]">
             <xsl:sort order="ascending" data-type="text"/>
            </xsl:apply-templates>
           </xsl:otherwise>
          </xsl:choose>
         </table>
        </xsl:when> <!-- test="$chars" -->
        <xsl:otherwise>
         <table width="100%">
          <tr>
           <xsl:call-template name="keyword-alphabet"/>
          </tr>
         </table>
        </xsl:otherwise>
       </xsl:choose>
      </td>
     </tr>

    </table>

    <xsl:call-template name="do_footer">
     <xsl:with-param name="html_dir" select="$html_dir"/>
     <xsl:with-param name="chars" select="$chars"/>
    </xsl:call-template>

   </body>
  </html>
 </xsl:template>

 <!-- make_debugpage-Template
  Erzeugt die Debugseite. Diese enthält alle Stichwörter in einer einfachen
  Tabelle.
 -->
 <xsl:template name="make_debugpage">
  <html>
   <xsl:call-template name="do_copyright"/>
   <head>
    <title>
     <xsl:text>SelfLinux - Stichwortverzeichnis (Debug-Version)</xsl:text>
    </title>
   </head>

   <body bgcolor="#FFFFFF">
    <table cellpadding="10" border="1">
     <xsl:apply-templates mode="keyword" select="//keyword">
      <xsl:sort order="ascending" data-type="text"/>
     </xsl:apply-templates>
    </table>
   </body>
  </html>
 </xsl:template>

 <!--
    *************************
    * Bibliotheksfunktionen *
    *************************

 Es folgen die Hilfsfunktionen für alle obigen Templates.

 vgl. auch dirs.xsl, lib.xsl
 -->

 <!-- do_copyright-Template
  Erzeugt den üblichen Copyright-Header für SelfLinux-Dateien
 -->
 <xsl:template name="do_copyright">
         <xsl:comment>
  * SelfLinux - Stichwortverzeichnis
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

 <!-- dir_path-Template
    Erzeugt die "Pfadangabe" des Verzeichnisses. Wie bei den Dokuenten sind 
    alle Pfadelemente bis auf den letzten Links auf die jeweiligen Seiten.
 -->
 <xsl:template name="dir_path">
  <xsl:param name="chars"/>

  <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
  <xsl:text>&#160;</xsl:text>
  <a href="../index.html">SelfLinux</a>
  <xsl:text>&#160;</xsl:text>
  <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
  <xsl:text>&#160;</xsl:text>
  <xsl:choose>
   <xsl:when test="$chars">
    <a href="keyword.html">Stichwortverzeichnis</a>
    <xsl:text>&#160;</xsl:text>
    <img src="../bilder/pfadpfeil.png" alt="&#187;" title=""/>
    <xsl:text>&#160;</xsl:text>
    <xsl:value-of select="substring($chars,2,1)"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>Stichwortverzeichnis</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- do_headline-Template
     Erzeugt die Kopfzeile (Pfadangabe, Versionsbezeichnung und der dünne
     dunklere Balken).
 -->
 <xsl:template name="do_headline">
  <xsl:param name="chars"/>
  <table width="95%" align="center">
   <tr>
    <td align="left">
     <xsl:call-template name="dir_path">
      <xsl:with-param name="chars" select="$chars"/>
     </xsl:call-template>
    </td>
    <td align="right">
     <xsl:value-of select="$version"/>
    </td>
   </tr>

   <tr>
    <td bgcolor="#c9d8e5" colspan="2">
     <table width="100%">
      <xsl:call-template name="do_prevnext">
       <xsl:with-param name="chars" select="$chars"/>
      </xsl:call-template>
     </table>
    </td>
   </tr>
  </table>
 </xsl:template>

 <!-- do_header-Template
     Erzeugt den Dokumentenheader (hellerer Balken mit SelfLinux-Logo und 
     dem Namen des aktuellen Dokuments)
 -->
 <xsl:template name="do_header">
  <xsl:param name="img_dir"/>
  <xsl:param name="chars"/>
  <tr>
   <td width="120">
    <img width="112" height="124" alt="SelfLinux-Logo">
     <xsl:attribute name="src">
      <xsl:value-of select="$img_dir"/>
      <xsl:text>/selflinux.png</xsl:text>
     </xsl:attribute>
    </img>
   </td>
   <td colspan="2" align="left" valign="middle" bgcolor="#f5f5f5" width="100%">
    <table width="100%">
     <tr>
      <td width="45">
       <img width="45" height="37" alt="Ordner" hspace="20" align="middle">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/openfolder.png</xsl:text>
        </xsl:attribute>
       </img>
      </td>
      <td align="left">
       <font size="+1">
        <xsl:text>Stichwortverzeichnis</xsl:text>
        <xsl:if test="$chars">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="substring($chars,2,1)"/>
         <xsl:text>)</xsl:text>
        </xsl:if>
       </font>
      </td>
     </tr>
    </table>
   </td>
  </tr>
 </xsl:template>

 <!-- do_footer-Template
     Erzeugt die Fußzeile (farbiger Balken am Ende des Dokuments).
 -->
 <xsl:template name="do_footer">
  <xsl:param name="html_dir"/>
  <xsl:param name="chars"/>

  <br/>
  <table width="95%" align="center">
   <tr>
    <td colspan="2" bgcolor="#c9d8e5">
     <table width="100%">
      <xsl:call-template name="do_prevnext">
       <xsl:with-param name="chars" select="$chars"/>
       <xsl:with-param name="pos">down</xsl:with-param>
      </xsl:call-template>
     </table>
    </td>
   </tr>
  </table>
 </xsl:template>

 <!-- do_prevnext-Template
     Erzeugt die Navigationszeile (mit den Pfeilen für Vor/Zurück), die in Kopf-
     und Fußzeile eingefügt wird.

     Der Parameter pos gibt an, ob die obere oder die undere Navigationszeile
     erzeugt wird, da der Link zum Dokumentenanfang nur unten eingefügt wird.
 -->
 <xsl:template name="do_prevnext">
  <xsl:param name="chars"/>
  <xsl:param name="pos"/>

  <tr>
   <td align="left">
    <!-- Link nach links -->
    <xsl:choose>
     <xsl:when test="$chars and (substring($chars,1,1) != ' ')">
      <a>
       <xsl:attribute name="href">
        <xsl:text>keyword-</xsl:text>
        <xsl:choose>
         <xsl:when test="substring($chars,1,1)='#'">
          <xsl:text>-</xsl:text>
         </xsl:when>
         <xsl:otherwise>
          <xsl:value-of select="substring($chars,1,1)"/>
         </xsl:otherwise>
        </xsl:choose>
        <xsl:text>.html</xsl:text>
       </xsl:attribute> <!-- href -->
       <img border="0" width="24" height="24">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/links.png</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:value-of select="substring($chars,1,1)"/>
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:value-of select="substring($chars,1,1)"/>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when> <!-- test="$chars ..." -->
     <xsl:when test="$chars and (substring($chars,1,1) = ' ')">
      <a href="keyword.html">
       <img border="0" width="24" height="24" alt="Stichwörter" title="Stichwörter">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/links.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when>
     <xsl:otherwise>
      <a href="../index.html">
       <img border="0" width="24" height="24" alt="SelfLinux" title="SelfLinux">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/links.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </xsl:otherwise>
    </xsl:choose>
   </td>
   <td align="left" width="25%">
    <xsl:text>&#160;</xsl:text>
   </td>
   <td align="center" width="50%">
    <!-- Top -->
    <xsl:if test="$pos = 'down'">
     <a href="#top">
      <img border="0" width="24" height="24" alt="Seitenanfang" title="Seitenanfang">
       <xsl:attribute name="src">
        <xsl:text>../bilder/top.png</xsl:text>
       </xsl:attribute>
      </img>
     </a>
     <xsl:text>&#160;</xsl:text>
    </xsl:if>

    <!-- Startseite -->
    <a href="../index.html">
     <img border="0" width="24" height="24" alt="Startseite" title="Startseite">
      <xsl:attribute name="src">
       <xsl:text>../bilder/start.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
    <xsl:text>&#160;</xsl:text>

    <!-- Kapitelanfang -->
    <xsl:if test="$chars">
     <a href="keyword.html">
      <img border="0" width="24" height="24" alt="Kapitelanfang" title="Kapitelanfang">
       <xsl:attribute name="src">
        <xsl:text>../bilder/kapitel.png</xsl:text>
       </xsl:attribute>
      </img>
     </a>
     <xsl:text>&#160;</xsl:text>
    </xsl:if>

    <!-- Inhaltsverzeichnis -->
    <a href="inhalt.html">
     <img border="0" width="24" height="24" alt="Inhaltsverzeichnis" title="Inhaltsverzeichnis">
      <xsl:attribute name="src">
       <xsl:text>../bilder/inhalt.png</xsl:text>
      </xsl:attribute>
     </img>
    </a>
   </td>
   <!-- Such-Formular für online-Version -->
   <xsl:choose>
    <xsl:when test="$variant = 'online'">
     <form action="http://www.selflinux.org/cgi-bin/htsearch">
      <td align="left" width="25%">
       <img src="../bilder/lupe.png" border="0" width="16" height="15" alt="Suchen" title="Suchen"/>
       <xsl:text>&#160;</xsl:text>
       <input type="text" name="words" size="10"/>
       <input type="hidden" name="method" value="and"/>
       <input type="hidden" name="config">
        <xsl:attribute name="value">
         <xsl:value-of select="$version"/>
        </xsl:attribute>
       </input>
      </td>
     </form>
    </xsl:when>
    <xsl:otherwise>
     <td align="right" width="25%">
      <xsl:text>&#160;</xsl:text>
     </td>
    </xsl:otherwise>
   </xsl:choose>

   <!-- Link nach rechts -->
   <td align="right">
    <xsl:choose>
     <xsl:when test="$chars and (substring($chars,3,1) != ' ')">
      <a>
       <xsl:attribute name="href">
        <xsl:text>keyword-</xsl:text>
        <xsl:value-of select="substring($chars,3,1)"/>
        <xsl:text>.html</xsl:text>
       </xsl:attribute>
       <img border="0" width="24" height="24">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/rechts.png</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="alt">
         <xsl:value-of select="substring($chars,3,1)"/>
        </xsl:attribute>
        <xsl:attribute name="title">
         <xsl:value-of select="substring($chars,3,1)"/>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when> <!-- test="$chars and ..." -->
     <xsl:when test="$chars and (substring($chars,3,1) = ' ')">
      <a href="../index.html">
       <img border="0" width="24" height="24" alt="SelfLinux" title="SelfLinux">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/rechts.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </xsl:when>
     <xsl:otherwise>
      <a href="keyword--.html">
       <img border="0" width="24" height="24" alt="#" title="#">
        <xsl:attribute name="src">
         <xsl:value-of select="$img_dir"/>
         <xsl:text>/rechts.png</xsl:text>
        </xsl:attribute>
       </img>
      </a>
     </xsl:otherwise>
    </xsl:choose>
   </td>
  </tr>
 </xsl:template>

</xsl:stylesheet>
