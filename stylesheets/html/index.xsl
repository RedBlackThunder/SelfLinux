<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * index.xsl - Erzeugt ein index-Dokument aus einem SelfLinux-Steuerdokument
 * Copyright Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.11 $
 * $Source: /selflinux/stylesheets/html/index.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: index.xsl,v 1.11 2004/03/31 15:09:16 florian Exp $
-->

<xsl:stylesheet version="1.1"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon">

 <xsl:param name="pwd"></xsl:param>  
 <xsl:param name="dest">index.xml</xsl:param>
 <xsl:param name="silent">false</xsl:param>
 <xsl:param name="debug">false</xsl:param>

 <!--
  Bedeutung der Parameter:
  pwd:  Der Pfad zum Tutorial-Verzeichnis. Alle Pfade im index-Dokument
        verstehen sich relativ zu diesem Verzeichnis.

  dest: Pfad und Dateiname des Ausgabedokuments. Der erweiterte Index wird dort
        gespeichert.

  silent: wird nicht genutzt.

  debug: Erzeuge zusätzliche Einträge fürs Debuggen von Links
 -->

 <xsl:output method="text" encoding="iso-8859-1"/>

 <!--
  Haupt-Template 
  Bearbeitet das Element selflinux, das Hauptelement des Index-Dokuments:

  Startet die Ausgabe auf $dest.
  Die Elemente cvs,publisher,description werden einfach übernommen.
  Danach werden alle Directories behandelt.
 -->
 
 <xsl:template match="selflinux">
  <xsl:document href="{$dest}" method="xml" indent="yes" encoding="ISO-8859-1">
   <xsl:copy>
    <xsl:apply-templates select="cvs|publisher|description" mode="copy"/>
    <xsl:apply-templates select="directory"/>
   </xsl:copy>
  </xsl:document>
 </xsl:template>

 <!--
  Directory-Template
  Die Dokumente sind in SelfLinux wie in einem UNIX-Dateisystem angeordnet.
  Jedes Directory kann Dokumente sowie weitere Directories enthalten.

  Alle Attribute des Directory-Tags werden übernommen.
  Danach werden alle untergeordneten Tags abgearbeitet.
 -->
 
 <xsl:template match="directory">
  <xsl:copy>
   <xsl:apply-templates select="@*" mode="copy"/>
   <xsl:apply-templates/>
  </xsl:copy>
 </xsl:template>

 <!--
  Document-Template
  Dient zum Einbinden eines Kapitels in das aktuelle Verzeichnis.
  Die im @file-Attribut angegebene Datei wird geparst und in den erweiterten
  Index aufgenommen.
 -->
 
 <xsl:template match="document">
  <xsl:variable name="filename">
   <xsl:value-of select="$pwd"/>/<xsl:value-of select="@file"/>
  </xsl:variable>
  <xsl:apply-templates select="document($filename)"/>
 </xsl:template>

 <!--
  Chapter-Template
  wird für jedes Kapitel einmal aufgerufen.

  übernimmt wichtige Attribute des chapter-Tags
  fügt das Attribut "minichapter=1" hinzu, wenn es sich um ein Mini-Kapitel handelt
  vermerkt den Dateinamen im file-Attribut
  kopiert wichtige Grunddaten aus den Tags cvs,title,author,layout und keyword
  durchläuft anschließend alle Splits, um die Abschnitte zu indizieren
 -->
 
 <xsl:template match="chapter">
  <chapter>
   <xsl:attribute name="index"><xsl:value-of select="normalize-space(index)"/></xsl:attribute>
   
   <!-- Mini-Kapitel auch im Index vermerken -->
   <xsl:if test="count(.//split/section)=1">
    <xsl:attribute name="minichapter">1</xsl:attribute>
   </xsl:if>
   <xsl:attribute name="file"><xsl:value-of select="saxon:system-Id()"/></xsl:attribute>
   <xsl:apply-templates select="cvs|title|author|layout|keyword" mode="copy"/>
   <xsl:apply-templates select="split"/>
  </chapter>
 </xsl:template>

 <!--
  section,textblock-Template
  Nimmt alle Abschnitte und benannte Textblöcke in den Index auf.

  Aus jedem Abschnitt oder Textblock wird hier ein Tag für den Index erzeugt.
  Er enthält den Namen des Abschnitts und einen eindeutigen Bezeichner, der
  später als Sprungziel in den HTML-Dokumenten genutzt wird.

  Schließlich werden auch noch alle untergeordneten Elemente geparsed.
 -->
 
 <xsl:template match="section|textblock[@name]">
  <xsl:copy>
   <xsl:attribute name="name">
    <xsl:choose>
     <xsl:when test="self::section">
      <xsl:value-of select="normalize-space(heading)"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="normalize-space(@name)"/>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>
   <xsl:attribute name="id"><xsl:value-of select="generate-id()"/></xsl:attribute>
   <xsl:attribute name="split"><xsl:number format="01" count="split" level="single"/></xsl:attribute>
   <xsl:attribute name="line"><xsl:value-of select="saxon:lineNumber()"/></xsl:attribute>
   <xsl:apply-templates select="*"/>
  </xsl:copy>
 </xsl:template>

 <!--
  Keyword-Template
  Schlüsselwörter (keyword-Tags) werden einfach in den Index übernommen.
 -->
 
 <xsl:template match="keyword">
  <xsl:apply-templates select="." mode="copy"/>
 </xsl:template>

 <!--
  ref-Template
  Falls debug gesetzt ist, werden alle ref-Tags in die Ausgabe übernommen
  und mit Zeilennummern versehen.
 -->
 
 <xsl:template match="ref">
  <xsl:if test="$debug = 'true'">
   <xsl:copy>
    <xsl:attribute name="line"><xsl:value-of select="saxon:lineNumber()"/></xsl:attribute>
    <xsl:apply-templates select="@*" mode="copy"/>
    <xsl:apply-templates mode="copy"/>
   </xsl:copy>
  </xsl:if>
 </xsl:template>

 <!--
  Dummy-Template
  Alle übrigen Tags werden nicht beachtet; lediglich die untergeordneten
  Tags werden geparsed.
-->

 <xsl:template match="*">
  <xsl:apply-templates select="*"/>
 </xsl:template>

 <!-- copy-Template 
  Allgemeine Kopierfunktion: Kopiert einen Tag 1:1 in das Ausgabedokument
 -->
 
 <xsl:template match="*|@*" mode="copy">
  <xsl:copy>
   <xsl:apply-templates select="@*" mode="copy"/>
   <xsl:apply-templates mode="copy"/>
  </xsl:copy>
 </xsl:template>

 <!--
  text-copy-Template
  Beim Kopieren von Texten werden Leerzeilen in Leerzeichen umgewandelt
  (br-to-space) und mehrere Leerzeichen zu einem zusammengefasst. (sp-squash)
 -->
 
 <xsl:template match="text()" mode="copy">
  <xsl:call-template name="sp-squash">
   <xsl:with-param name="text">
    <xsl:call-template name="br-to-space">
     <xsl:with-param name="text" select="."/>
    </xsl:call-template>
   </xsl:with-param>
  </xsl:call-template>
 </xsl:template>

 <!--
  br-to-space
  Der im Parameter text angegebene String wird ausgegeben, wobei alle
  Zeilenwechsel durch Leerzeichen ersetzt werden.

  Die Einschränkungen von XSLT erfordern das recht komplizierte Vorgehen.
 -->   
 
 <xsl:template name="br-to-space">
  <xsl:param name="text"/>
  <xsl:variable name="cr" select="'&#xa;'"/>
  <xsl:choose>
   <!-- If the value of the $text parameter contains a carriage return... -->
   <xsl:when test="contains($text,$cr)">
    <!-- Return the substring of $text before the carriage return -->
    <xsl:value-of select="substring-before($text,$cr)"/>
    <xsl:if test="translate(substring-after($text,$cr),' &#09;','')">
     <xsl:text> </xsl:text>
     
     <!--
      Then invoke this same template again, passing the
      substring *after* the carriage return as the new "$text" to
      consider for replacement
     -->
     
     <xsl:call-template name="br-to-space">
      <xsl:with-param name="text" select="substring-after($text,$cr)"/>
     </xsl:call-template>
    </xsl:if>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$text"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  sp-squash
  Der im Parameter text angegebene String wird ausgegeben, wobei zwei oder
  mehr Leerzeichen in Folge durch ein einziges Leerzeichen ersetzt werden.

  Die Einschränkungen von XSLT erfordern das recht komplizierte Vorgehen.
 -->
 
 <xsl:template name="sp-squash">
  <xsl:param name="text"/>
  <!-- NOTE: There are two spaces   ** here below -->
   <xsl:variable name="sp"><xsl:text>  </xsl:text></xsl:variable>
   <xsl:choose>
    <xsl:when test="contains($text,$sp)">
     <xsl:value-of select="substring-before($text,$sp)"/>
     <xsl:choose>
      <xsl:when test="translate(substring-after($text,$sp),' ','')">
       <xsl:call-template name="sp-squash">
        <xsl:with-param name="text" select="substring-after($text,$sp)"/>
       </xsl:call-template>
      </xsl:when>
     </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
    <xsl:if test="translate($text,' ','')">
     <xsl:value-of select="$text"/>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
