<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="table">
  <fo:block
   font-family="serif"
   font-size="10pt"
   space-before="5pt"
   space-after="5pt">
   <fo:table
    table-layout="fixed"
    padding="5pt"
    border-style="solid">
    <xsl:attribute name="width">
     <xsl:choose>
      <xsl:when test="@pdf-width">
       <xsl:value-of select="@pdf-width"/>%
      </xsl:when>
      <xsl:otherwise>
       100%
      </xsl:otherwise>
     </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="border-width">
     <xsl:choose>
      <xsl:when test="@border">
       <xsl:value-of select="@border"/>px
      </xsl:when>
      <xsl:otherwise>
       0px
      </xsl:otherwise>
     </xsl:choose>
    </xsl:attribute>
    <xsl:apply-templates select="pdf-column"/>
    <fo:table-body>
     <xsl:apply-templates select="tr"/>
    </fo:table-body>
   </fo:table>
  </fo:block>
 </xsl:template>

 <xsl:template match="table/pdf-column">
  <fo:table-column>
   <xsl:attribute name="column-width">
    <xsl:choose>
     <xsl:when test="@width">
      <xsl:value-of select="@width"/>px
     </xsl:when>
     <xsl:otherwise>
      proportional-column-width(1)
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>
  </fo:table-column>
 </xsl:template>

 <xsl:template match="table/tr">
  <fo:table-row>
   <xsl:apply-templates/>
  </fo:table-row>
 </xsl:template>

 <xsl:template match="table/tr/th">
  <fo:table-cell>
   <fo:block
    font-size="12pt"
    font-weight="bold">
    <xsl:apply-templates/>
   </fo:block>
  </fo:table-cell>
 </xsl:template>

 <xsl:template match="table/tr/td">
  <fo:table-cell>
   <fo:block>
    <xsl:apply-templates/>
   </fo:block>
  </fo:table-cell>
 </xsl:template>

</xsl:stylesheet>
