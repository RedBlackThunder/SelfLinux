<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * toc.xsl - Templates zur Erstellung eines Inhaltsverzeichnisses
 * Copyright Peter Schneewind, Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.20 $
 * $Source: /selflinux/stylesheets/html/toc.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: toc.xsl,v 1.20 2004/04/04 00:25:51 florian Exp $
-->

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon">

 <!--
  Vorlage zur Erstellung eines Inhaltsverzeichnisses (index.html)
  des Kapitels.
 -->
 
 <xsl:template name="toc">
  <xsl:param name="toc-level">0</xsl:param>

  <tr>
   <td valign="top">
    <xsl:text>&#160;</xsl:text>
   </td>
   <td colspan="2">

    <!-- Kapitel-Beschreibung -->
    <br/>
    <xsl:apply-templates select="/chapter/description"/>
    <br/>

    <h4>Inhalt</h4>

    <!-- Ausgabe des Inhaltsverzeichnisses (s.u.) -->
    <xsl:for-each select="split/section">
     <xsl:call-template name="do_toc">
      <xsl:with-param name="toc-level" select="$toc-level + 1"/>
     </xsl:call-template>
    </xsl:for-each>
    <br/><br/>
   </td>
  </tr>
  <tr>
   <td vlaign="top">
    <xsl:text>&#160;</xsl:text>
   </td>
   <td bgcolor="#f5f5f5" colspan="2">

    <!-- Autoren/Layouter -->
    <xsl:call-template name="do_author"/>
   </td>
  </tr>
 </xsl:template>

 <xsl:template match="chapter/description">
  <h4>Beschreibung</h4>
  <xsl:apply-templates/>
 </xsl:template>

 <!--
  Die benannte Vorlage "do_toc" gibt die Ueberschriften der einzelnen
  "sections" als Hyperlink aus, ggf. auch rekursiv (wenn eine "section"
  ihrerseits "sections" enthaelt).
 -->

 <xsl:template name="do_toc">
  <xsl:param name="toc-level"/>
  <table>
   <xsl:attribute name="style">
    <xsl:text>margin-left:</xsl:text>
    <xsl:value-of select="$toc-level"/>
    <xsl:text>em; margin-top:1px; margin-bottom:1px;</xsl:text>
   </xsl:attribute>
   <tr>
    <td valign="top">
     <strong>
      <xsl:number format="1" count="split/section" level="any"/>
      <xsl:if test="parent::section">
       <xsl:number format=".1 " count="section/section" level="multiple"/>
      </xsl:if>
     </strong>
    </td>
    <td valign="top">
     <a>
      <xsl:attribute name="href">
       <xsl:call-template name="refthis"/>
      </xsl:attribute>
      <xsl:value-of select="heading"/>
     </a>
    </td>
   </tr>
  </table>

  <xsl:for-each select="./section">
   <xsl:call-template name="do_toc">
    <xsl:with-param name="toc-level" select="$toc-level + 1"/>
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>

</xsl:stylesheet>
