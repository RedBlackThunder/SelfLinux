<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="image">
  <fo:table
   table-layout="fixed"
   width="100%">
   <fo:table-column column-width="proportional-column-width(1)"/>
   <fo:table-body>
    <fo:table-row keep-with-next="always">
     <fo:table-cell display-align="center">
      <fo:block
       space-before="10pt"
       space-after="5pt"
       text-align="center">
       <fo:external-graphic>
        <xsl:attribute name="src">
         <xsl:value-of select="filename"/>
        </xsl:attribute>
        <xsl:if test="@height">
         <xsl:attribute name="height">
          <xsl:value-of select="@height"/>px
         </xsl:attribute>
        </xsl:if>
        <xsl:if test="@width">
         <xsl:attribute name="width">
          <xsl:value-of select="@width"/>px
         </xsl:attribute>
        </xsl:if>
       </fo:external-graphic>
      </fo:block>
     </fo:table-cell>
    </fo:table-row>
    <fo:table-row>
     <fo:table-cell display-align="center">
      <xsl:apply-templates/>
     </fo:table-cell>
    </fo:table-row>
   </fo:table-body>
  </fo:table>
 </xsl:template>

 <xsl:template match="image/title">
  <fo:block
   font-family="serif"
   font-size="8pt"
   space-after="10pt"
   text-align="center">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="image/filename">
  <fo:block>
  </fo:block>
 </xsl:template>

</xsl:stylesheet>
