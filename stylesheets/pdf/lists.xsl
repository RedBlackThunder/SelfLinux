<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:template match="ul">
  <xsl:param name="lists-level">0</xsl:param>
  <fo:block
   space-before="5pt"
   space-after="5pt">
   <fo:list-block>
    <xsl:apply-templates>
     <xsl:with-param name="lists-level" select="$lists-level"/>
    </xsl:apply-templates>
   </fo:list-block>
  </fo:block>
 </xsl:template>

 <xsl:template match="li/ul">
  <xsl:param name="lists-level"/>
  <fo:block
   space-before="5pt"
   space-after="5pt">
   <fo:list-block>
    <xsl:apply-templates>
     <xsl:with-param name="lists-level" select="$lists-level"/>
    </xsl:apply-templates>
   </fo:list-block>
  </fo:block>
 </xsl:template>

 <xsl:template match="ul/li">
  <xsl:param name="lists-level"/>
  <fo:list-item>
   <fo:list-item-label>
    <xsl:attribute name="start-indent">
     <xsl:value-of select="$lists-level + 1"/>em
    </xsl:attribute>
    <fo:block
     font-family="serif"
     font-size="10pt">
     *
    </fo:block>
   </fo:list-item-label>
   <fo:list-item-body
    font-family="serif"
    font-size="10pt">
    <xsl:attribute name="start-indent">
     <xsl:value-of select="$lists-level + 2"/>em
    </xsl:attribute>
    <fo:block>
     <xsl:apply-templates>
      <xsl:with-param name="lists-level" select="$lists-level + 1"/>
     </xsl:apply-templates>
    </fo:block>
   </fo:list-item-body>
  </fo:list-item>
 </xsl:template>

 <xsl:template match="ol">
  <xsl:param name="lists-level">0</xsl:param>
  <fo:block
   space-before="5pt"
   space-after="5pt">
   <fo:list-block>
    <xsl:apply-templates>
     <xsl:with-param name="lists-level" select="$lists-level"/>
    </xsl:apply-templates>
   </fo:list-block>
  </fo:block>
 </xsl:template>

 <xsl:template match="li/ol">
  <xsl:param name="lists-level"/>
  <fo:block
   space-before="5pt"
   space-after="5pt">
   <fo:list-block>
    <xsl:apply-templates>
     <xsl:with-param name="lists-level" select="$lists-level"/>
    </xsl:apply-templates>
   </fo:list-block>
  </fo:block>
 </xsl:template>

 <xsl:template match="ol/li">
  <xsl:param name="lists-level"/>
  <fo:list-item>
   <fo:list-item-label>
    <xsl:attribute name="start-indent">
     <xsl:value-of select="$lists-level + 1"/>em
    </xsl:attribute>
    <fo:block
     font-family="serif"
     font-size="10pt">
     <xsl:number format="1."/>
    </fo:block>
   </fo:list-item-label>
   <fo:list-item-body
    font-family="serif"
    font-size="10pt">
    <xsl:attribute name="start-indent">
     <xsl:value-of select="$lists-level + 2"/>em
    </xsl:attribute>
    <fo:block>
     <xsl:apply-templates>
      <xsl:with-param name="lists-level" select="$lists-level + 1"/>
     </xsl:apply-templates>
    </fo:block>
   </fo:list-item-body>
  </fo:list-item>
 </xsl:template>

</xsl:stylesheet>
