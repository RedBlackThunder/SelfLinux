<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="file">
  <fo:block
   font-family="serif"
   font-size="10pt"
   space-before="5pt"
   space-after="5pt">
   <fo:table table-layout="fixed" width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-body>
     <xsl:apply-templates select="title"/>
     <xsl:apply-templates select="content"/>
    </fo:table-body>
   </fo:table>
  </fo:block>
 </xsl:template>

  <xsl:template match="file/title">
   <fo:table-row
    keep-with-next="always">
    <fo:table-cell
     display-align="center"
     border-width="1px"
     border-style="solid"
     padding="5pt">
     <fo:block text-align="center">
      <xsl:apply-templates/>
     </fo:block>
    </fo:table-cell>
   </fo:table-row>
  </xsl:template>

  <xsl:template match="file/content">
   <fo:table-row>
    <fo:table-cell
     border-width="1px"
     border-style="solid"
     padding="5pt"
     background-color="rgb(255, 253, 196)">
     <fo:block
      font-family="monospace"
      font-size="8pt"
      white-space-collapse="false"
      linefeed-treatment="preserve"
      white-space-treatment="preserve">
      <xsl:apply-templates/>
     </fo:block>
    </fo:table-cell>
   </fo:table-row>
  </xsl:template>

</xsl:stylesheet>
