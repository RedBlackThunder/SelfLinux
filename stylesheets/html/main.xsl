<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * main.xsl - Root-Template für das Parsen einer XML-Datei
 * Copyright Peter Schneewind, Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.17 $
 * $Source: /selflinux/stylesheets/html/main.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.de
 *
 *** $Id: main.xsl,v 1.17 2004/04/09 16:12:43 florian Exp $
-->

 <xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://icl.com/saxon"
  extension-element-prefixes="saxon">

 <!-- Variablen definieren -->
 <xsl:param name="html_dir">html</xsl:param>
 <xsl:param name="index">none</xsl:param>
 <xsl:param name="variant">.</xsl:param>
 <xsl:param name="pdfsize">.</xsl:param>
 <xsl:param name="silent">false</xsl:param>
 <xsl:param name="debug">false</xsl:param>
 <xsl:param name="version">.</xsl:param>

 <xsl:variable name="img_dir">../bilder</xsl:variable>
 <xsl:variable name="chapter_index"><xsl:value-of select="normalize-space(/chapter/index)"/></xsl:variable>

 <!-- Externe Vorlagen einbinden -->
 <xsl:include href="lib.xsl"/>
 <xsl:include href="files.xsl"/>
 <xsl:include href="toc.xsl"/>
 <xsl:include href="section.xsl"/>
 <xsl:include href="format.xsl"/>
 <xsl:include href="debuginfos.xsl"/>

 <!--
  Die Vorlage fuer den Root-Knoten (nicht das Root-Element) ist der
  Startpunkt der Transformation. Hier wird in die Vorlagen zur Erstellung
  einer TOC-Datei fuer das Kapitel und einer HTML-Datei je "split"-Element
  verzweigt.
 -->

 <xsl:template match="/">
  <xsl:if test="$index = 'none'">
   <xsl:message terminate="no">
HINWEIS: Es wird kein Index-Dokument verwendet, daher können manche irefs nicht aufgelöst werden.
   </xsl:message>
  </xsl:if>

  <xsl:if test="count(//split/section) > 1">
   <xsl:apply-templates select="chapter" mode="toc"/>
  </xsl:if>

  <xsl:apply-templates select="chapter"/>
 </xsl:template>

</xsl:stylesheet>
