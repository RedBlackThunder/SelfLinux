<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * debuglinks.xsl - Erzeugt eine Übersichtsseite über alle externen Links
 * Copyright Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.2 $
 * $Source: /selflinux/stylesheets/html/debuglinks.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: debuglinks.xsl,v 1.2 2004/03/31 15:09:16 florian Exp $
-->

<xsl:stylesheet version="1.1"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon">

 <xsl:output method="html" indent="yes" encoding="ISO-8859-1"/>

 <xsl:template match="/">
  <html>
   <head>
    <title>SelfLinux: Debuginfos zu externen Links</title>
   </head>
   <body>
    <xsl:call-template name="process-extrefs"/>
   </body>
  </html>
 </xsl:template>

 <xsl:template name="process-extrefs">
  <table border="1">
   <tr>
    <th>Link</th>
    <th>Datei</th>
    <th>Zeilennummer</th>
   </tr>
   <xsl:for-each select="descendant::ref[@url]">
   <tr>
    <td>
     <xsl:if test="@lang='de' or @lang='en'">
      <xsl:text>{</xsl:text>
      <xsl:value-of select="@lang"/>
      <xsl:text>}&#160;</xsl:text>
     </xsl:if>
     <a target="_blank">
      <xsl:attribute name="href">
       <xsl:value-of select="normalize-space(@url)"/>
      </xsl:attribute>
      <xsl:apply-templates/>
     </a>
     </td>
     <td>
      <xsl:choose>
       <xsl:when test="ancestor::chapter">
        <a>
         <xsl:attribute name="href">
          <xsl:apply-templates mode="refindex" select="ancestor::*[self::chapter or self::section][1]"/>
         </xsl:attribute>
         <xsl:value-of select="ancestor::chapter/@index"/>
        </a>
       </xsl:when>
       <xsl:otherwise>
        <xsl:text>index.xml</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </td>
     <td>
      <xsl:value-of select="@line"/>
     </td>
    </tr>
   </xsl:for-each>
  </table>
 </xsl:template>

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
