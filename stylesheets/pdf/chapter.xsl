<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="chapter/title">
  <fo:block
   font-size="24pt">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="chapter/title" mode="header">
  <fo:block
   font-size="12pt"
   font-weight="bold">
   <xsl:apply-templates/>
   <xsl:text>&#160;</xsl:text>
   <fo:external-graphic
    height="10px">
    <xsl:attribute name="src">file:///<xsl:value-of select="$img_dir"/>/document.png</xsl:attribute>
   </fo:external-graphic>
  </fo:block>
 </xsl:template>

 <xsl:template match="chapter/author">
  <fo:block
   font-family="serif"
   font-size="12pt">
   <xsl:text>Autor: </xsl:text>
   <xsl:apply-templates select="name"/>
   <xsl:text> (</xsl:text>
   <fo:wrapper font-style="italic">
    <xsl:apply-templates select="mailto"/>
   </fo:wrapper>
   <xsl:text>)</xsl:text>
  </fo:block>
 </xsl:template>

 <xsl:template match="chapter/author/name">
  <fo:inline>
   <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="chapter/layout">
  <fo:block
   font-family="serif"
   font-size="12pt">
   <xsl:text>Formatierung: </xsl:text>
   <xsl:apply-templates select="name"/>
   <xsl:text> (</xsl:text>
   <fo:wrapper font-style="italic">
    <xsl:apply-templates select="mailto"/>
   </fo:wrapper>
   <xsl:text>)</xsl:text>
  </fo:block>
 </xsl:template>

 <xsl:template match="chapter/layout/name">
  <fo:inline>
   <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="chapter/license">
  <fo:block
   font-family="serif"
   font-size="12pt">
   <xsl:text>Lizenz: </xsl:text>
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="chapter/description">
  <fo:block
   font-family="serif"
   font-size="10pt">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="chapter/split">
  <fo:block break-before="page"/>
  <xsl:apply-templates select="section"/>
 </xsl:template>

</xsl:stylesheet>
