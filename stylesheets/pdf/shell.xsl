<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="shell">
  <fo:block
   font-family="monospace"
   font-size="10pt"
   space-before="5pt"
   space-after="5pt">
   <fo:table
    table-layout="fixed"
    width="100%">
    <fo:table-column column-width="proportional-column-width(1)"/>
    <fo:table-body>
     <fo:table-row>
      <fo:table-cell
       border-width="1px"
       border-style="solid"
       padding="5pt">
       <xsl:apply-templates/>
      </fo:table-cell>
     </fo:table-row>
    </fo:table-body>
   </fo:table>
  </fo:block>
 </xsl:template>

 <xsl:template match="shell/root">
  <fo:block>
   <fo:inline
    color="rgb(170,0,0)">
    <xsl:text>root@linux </xsl:text>
   </fo:inline>
   <fo:inline
    color="rgb(51,51,255)">
    <xsl:value-of select="@path"/>
    <xsl:text>/ # </xsl:text>
   </fo:inline>
   <fo:inline
    color="rgb(51, 51, 255)">
    <xsl:apply-templates/>
   </fo:inline>
  </fo:block>
 </xsl:template>

 <xsl:template match="shell/user">
  <fo:block>
   <fo:inline
    color="rgb(0,0,170)">
    <xsl:text>user@linux </xsl:text>
   </fo:inline>
   <fo:inline
    color="rgb(51,51,255)">
    <xsl:value-of select="@path"/>
    <xsl:text>/ $ </xsl:text>
   </fo:inline>
   <fo:inline
    color="rgb(51, 51, 255)">
    <xsl:apply-templates/>
   </fo:inline>
  </fo:block>
 </xsl:template>

 <xsl:template match="shell/input">
  <fo:block
   color="rgb(51, 51, 255)">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="shell/output">
  <fo:block
   white-space-collapse="false"
   linefeed-treatment="preserve"
   white-space-treatment="preserve">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

</xsl:stylesheet>
