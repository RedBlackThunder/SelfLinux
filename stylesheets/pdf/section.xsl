<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="split/section" mode="bookmark">
  <fox:outline>
   <xsl:attribute name="internal-destination">
    <xsl:value-of select="normalize-space(heading)"/>
   </xsl:attribute>
   <fox:label>
    <xsl:number
     format="1"
     count="split/section"
     level="any"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(heading)"/>
   </fox:label>
   <xsl:apply-templates select="section" mode="bookmark"/>
  </fox:outline>
 </xsl:template>

 <xsl:template match="section/section" mode="bookmark">
  <fox:outline>
   <xsl:attribute name="internal-destination">
    <xsl:value-of select="normalize-space(heading)"/>
   </xsl:attribute>
   <fox:label>
    <xsl:number
     format="1"
     count="split/section/heading"
     level="any"/>
    <xsl:number
     format=".1"
     count="section/section"
     level="multiple"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(heading)"/>
   </fox:label>
   <xsl:apply-templates select="section" mode="bookmark"/>
  </fox:outline>
 </xsl:template>

 <xsl:template match="split/section" mode="toc">
  <xsl:param name="section-level">0</xsl:param>
  <xsl:apply-templates select="heading|section" mode="toc">
   <xsl:with-param name="section-level" select="$section-level"/>
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="section/section" mode="toc">
  <xsl:param name="section-level"/>
  <fo:block>
   <xsl:attribute name="start-indent">
    <xsl:value-of select="$section-level + 1"/>em
   </xsl:attribute>
   <xsl:apply-templates select="heading|section" mode="toc">
    <xsl:with-param name="section-level" select="$section-level + 1"/>
   </xsl:apply-templates>
  </fo:block>
 </xsl:template>

 <xsl:template match="split/section/heading">
  <fo:block
   font-family="serif"
   font-size="16pt"
   font-weight="bold"
   space-before="10pt"
   space-after="10pt">
   <xsl:attribute name="id">
    <xsl:value-of select="normalize-space(../heading)"/>
   </xsl:attribute>
   <xsl:number
    format="1"
    count="split/section/heading"
    level="any"/>
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="split/section/heading" mode="toc">
  <fo:block
   font-family="serif"
   font-size="10pt"
   font-weight="bold"
   space-before="10pt"
   space-after="5pt">
   <xsl:number
    format="1"
    count="split/section"
    level="any"/>
   <fo:basic-link>
    <xsl:attribute name="internal-destination">
     <xsl:value-of select="normalize-space(../heading)"/>
    </xsl:attribute>
    <xsl:apply-templates mode="toc"/>
   </fo:basic-link>
  </fo:block>
 </xsl:template>

 <xsl:template match="section/section/heading">
  <fo:block
   font-family="serif"
   font-size="12pt"
   font-weight="bold"
   space-before="10pt"
   space-after="5pt">
   <xsl:attribute name="id">
    <xsl:value-of select="normalize-space(../heading)"/>
   </xsl:attribute>
   <xsl:number
    format="1"
    count="split/section/heading"
    level="any"/>
   <xsl:number
    format=".1"
    count="section/section"
    level="multiple"/>
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="section/section/heading" mode="toc">
  <fo:block
   font-family="serif"
   font-size="10pt">
   <xsl:number
    format="1"
    count="split/section/heading"
    level="any"/>
   <xsl:number
    format=".1"
    count="section/section"
    level="multiple"/>
   <fo:basic-link>
    <xsl:attribute name="internal-destination">
     <xsl:value-of select="normalize-space(../heading)"/>
    </xsl:attribute>
    <xsl:apply-templates mode="toc"/>
   </fo:basic-link>
  </fo:block>
 </xsl:template>

</xsl:stylesheet>
