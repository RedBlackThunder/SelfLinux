<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * files.xsl - Templates, die Ausgabedateien erzeugen
 * Copyright Peter Schneewind, Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.15 $
 * $Source: /selflinux/stylesheets/html/files.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: files.xsl,v 1.15 2004/04/09 16:12:43 florian Exp $
-->
 
<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon">

 <!--
  In dieser Datei befinden sich alle Templates, die Dateinamen erzeugen.
 -->

 <!-- split-Template
  Diese Vorlage erzeugt eine HTML-Ausgabedatei fuer jedes "split", auf
  das sie angewendet wird.
 -->

 <xsl:template match="split">

  <!-- Den Namen der Ausgabedatei bestimmen -->
  <xsl:variable name="html_file">
   <xsl:choose>
    <xsl:when test="count(//split/section) = 1">
     <xsl:value-of select="normalize-space(/chapter/index)"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="normalize-space(/chapter/index)"/>
     <xsl:number format="01"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

 <!-- Die Ausgabe wird mit der Saxon-Erweiterung "saxon:output" erzeugt -->
  <saxon:output method="html"
   href="{$html_dir}/{$html_file}.html"
   encoding="iso-8859-1"
   indent="yes"
   doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN&quot; &quot;http://www.w3.org/TR/html4/loose.dtd"
   cdata-section-elements="line">

  <html>
   <xsl:call-template name="do_copyright"/>
   <head>
    <title><xsl:value-of select="/chapter/title"/></title>
   </head>

   <body bgcolor="#FFFFFF">
    <a name="top"/>
     <xsl:call-template name="do_headline"/>

     <!-- Seitenrahmen -->
     <table width="95%" align="center" cellspacing="0" cellpadding="5">

      <!-- Kopfzeile -->
      <xsl:call-template name="do_header"/>

      <!-- Ausgabe des eigentlichen Dokumentes -->
      <tr>
       <td valign="top">
        <xsl:text>&#160;</xsl:text>
       </td>
       <td colspan="2">
        <xsl:apply-templates select="section"/>
        <br/>
       </td>
      </tr>

      <xsl:if test="count(//split/section) = 1">
       <tr>
        <td valign="top">
         <xsl:text>&#160;</xsl:text>
        </td>
        <td bgcolor="#f5f5f5" colspan="2">

         <!-- Autoren/Layouter -->
         <xsl:call-template name="do_author"/>
        </td>
       </tr>
      </xsl:if>
     </table>

     <!-- Fusszeile -->
     <xsl:call-template name="do_footer"/>
    </body>
   </html>
  </saxon:output>
 </xsl:template>

 <!-- chapter-Template
  Ruft lediglich chapter/split auf.
 -->

 <xsl:template match="chapter">
  <xsl:apply-templates select="split"/>
 </xsl:template>

 <!-- chapter-Template
  Erzeugt das Inhaltsverzeichnis (TOC) aus dem aktuellen Kapitel.

  Das eigentliche Inhaltsverzeichnis erstellt das Template toc aus toc.xsl
 -->

 <xsl:template match="chapter" mode="toc">
  <xsl:variable name="html_file">
   <xsl:value-of select="normalize-space(/chapter/index)"/>
  </xsl:variable>

  <saxon:output method="html"
   href="{$html_dir}/{$html_file}.html"
   encoding="ISO-8859-1"
   doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN&quot; &quot;http://www.w3.org/TR/html4/loose.dtd"
   indent="yes">

   <html>
    <xsl:call-template name="do_copyright"/>
    <head>
     <title><xsl:value-of select="title"/>-Index</title>
    </head>

    <body bgcolor="#FFFFFF">
     <a name="top"/>
     <xsl:call-template name="do_headline"/>

     <!-- Seitenrahmen -->
     <table width="95%" align="center" cellspacing="0" cellpadding="5">

      <!-- Kopfzeile (siehe lib.xsl) -->
      <xsl:call-template name="do_header"/>

      <!-- Inhaltsverzeichnis -->
      <xsl:call-template name="toc"/>
     </table>

     <!-- Fusszeile -->
     <xsl:call-template name="do_footer"/>
    </body>
   </html>
  </saxon:output>
 </xsl:template>

 <!-- refthis-Template 
  Dieses Template kann für section und textblock-Elemente eines 
  Kapitels *in der Originaldatei* aufgerufen werden.

  Es erzeugt den Text für das href-Attribut, um einen Link auf das 
  aktuelle section/textblock-Element zu setzen.

  Dieser Block kann sowohl über apply-templates (mit mode=ref) als auch
  über call-template (mit name=refthis) aufgerufen werden.
 -->
 
 <xsl:template match="section|textblock" mode="ref" name="refthis">
  <xsl:value-of select="normalize-space(/chapter/index)"/>
   <xsl:if test="count(//split/section) > 1">
    <xsl:number format="01" count="split" level="single"/>
   </xsl:if>
   <xsl:text>.html#</xsl:text>
   <xsl:choose>
    <xsl:when test="$index='none'">
     <xsl:value-of select="generate-id()"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:variable name="section_nr"><xsl:number level="any"/></xsl:variable>
     <xsl:value-of select="document($index)//chapter[@index=$chapter_index]/descendant::section[position()=$section_nr]/@id"/>
    </xsl:otherwise>
   </xsl:choose>
 </xsl:template>

 <!-- refindex-Templates
  Die folgenden zwei Templates können für chapter,section und
  textblock-Elemente eines Kapitels *im index.xsl-Dokument* aufgerufen werden.

  Es erzeugt den Text für das href-Attribut, um einen Link auf das aktuelle
  Element zu setzen.

  Der Block für section/textblock-Elemente kann auch mit call-template (name=refindex) aufgerufen werden.
 -->
 
 <xsl:template match="chapter" mode="refindex">
  <xsl:value-of select="normalize-space(@index)"/>
  <xsl:text>.html</xsl:text>
 </xsl:template>

 <xsl:template match="section|textblock" mode="refindex" name="refindex">
  <xsl:value-of select="ancestor::chapter[1]/@index"/>
  <xsl:if test="not(ancestor::chapter[1]/@minichapter)">
   <xsl:value-of select="@split"/>
  </xsl:if>
  <xsl:text>.html#</xsl:text>
  <xsl:value-of select="@id"/>
 </xsl:template>

</xsl:stylesheet>
