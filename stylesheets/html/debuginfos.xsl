<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * debuginfos.xsl - Hilfsfunktionene zum Erstellen von Debug-Infos
 * Copyright Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.2 $
 * $Source: /selflinux/stylesheets/html/debuginfos.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.de
 *
 *** $Id: debuginfos.xsl,v 1.2 2004/03/31 15:09:16 florian Exp $
-->

 <xsl:stylesheet version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://icl.com/saxon"
  extension-element-prefixes="saxon">

 <xsl:template name="linkstohere" >
  <xsl:variable name="chapter" select="normalize-space(ancestor-or-self::chapter/index)"/>
  <xsl:variable name="section">
   <xsl:if test="self::textblock">
    <xsl:value-of select="normalize-space(@name)"/>
   </xsl:if>
   <xsl:if test="self::section">
    <xsl:value-of select="normalize-space(heading)"/>
   </xsl:if>
  </xsl:variable>

  <xsl:if test="$index != 'none'">
   <xsl:for-each select="document($index)//ref[@chapter=$chapter and (@iref=$section or ($section = '' and not(@iref)))]">
    <a>
     <xsl:attribute name="href">
      <xsl:apply-templates mode="refindex" select="ancestor::*[self::chapter or self::section][1]"/>
     </xsl:attribute>
     <xsl:value-of select="ancestor::chapter/@index"/>
     (<xsl:value-of select="ancestor::section[1]/@name"/>)
    </a>
    <br/>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>

 <xsl:template name="debug-ch-infobox">
  <table bgcolor="#CCCCCC">
   <tr>
    <td>
     <strong><xsl:text>Stichwörter: </xsl:text></strong>
     <xsl:for-each select="keyword">
      <xsl:if test="position() > 1">
       <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:value-of select="."/>
     </xsl:for-each>
     <br/>
     <xsl:if test="$index != 'none'">
      <strong><xsl:text>Links auf dieses Kapitel:</xsl:text></strong>
      <br/>
      <xsl:call-template name="linkstohere"/>
     </xsl:if>
    </td>
   </tr>
  </table>
 </xsl:template>

 <xsl:template name="keyword-list">
  <table border="1">
   <tr>
    <th>Stichwort</th>
    <th>Kapitel</th>
    <th>Zeilennummer</th>
   </tr>
   <xsl:for-each select="//keyword">
    <xsl:sort order="ascending" data-type="text" select="."/>
    <tr>
     <td>
      <xsl:value-of select="."/>
     </td>
     <td>
      <xsl:for-each select="ancestor::section">
       <xsl:if test="position() > 1">
        <br/>
        <xsl:text>-></xsl:text>
       </xsl:if>
       <xsl:value-of select="heading"/>
       <xsl:text> </xsl:text>
      </xsl:for-each>
     </td>
     <td>
      <xsl:value-of select="saxon:lineNumber()"/>
     </td>
    </tr>
   </xsl:for-each>
  </table>
 </xsl:template>

</xsl:stylesheet>
