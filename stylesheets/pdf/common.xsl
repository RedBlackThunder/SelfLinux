<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:template match="keyword">
 </xsl:template>

 <xsl:template match="textblock">
  <fo:block
   font-family="serif"
   font-size="10pt"
   text-align="justify"
   space-before="5pt"
   space-after="5pt">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="definition">
  <fo:block
   font-family="serif"
   font-size="10pt"
   space-before="5pt"
   space-after="5pt">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="hint">
  <fo:block
   font-family="serif"
   font-size="10pt"
   space-before="5pt"
   space-after="5pt">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="name">
  <xsl:choose>
   <xsl:when test="@email">
    <fo:external-graphic>
     <xsl:attribute name="src">file:///<xsl:value-of select="$img_dir"/>/email.png</xsl:attribute>
    </fo:external-graphic>
    <xsl:text>&#160;</xsl:text>
    <fo:inline
     font-style="italic"
     color="rgb(51, 51, 255)"
     text-decoration="underline">
     <fo:basic-link>
      <xsl:attribute name="external-destination">
       <xsl:value-of select="@email"/>
      </xsl:attribute>
      <xsl:apply-templates/>
     </fo:basic-link>
    </fo:inline>
   </xsl:when>
   <xsl:otherwise>
    <fo:inline
     font-style="italic">
     <xsl:apply-templates/>
    </fo:inline>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="command">
  <fo:inline
   font-family="monospace"
   color="rgb(170, 85, 34)">
   <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="keycomb">
  <fo:inline
   font-family="monospace">
   <xsl:for-each select="key">
    <xsl:apply-templates/>
    <xsl:if test="following-sibling::key">
     +
    </xsl:if>
   </xsl:for-each>
  </fo:inline>
 </xsl:template>

 <xsl:template match="key">
  <fo:inline>
   <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="path">
  <fo:inline
   color="rgb(39, 119, 23)">
   <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="strong">
  <fo:inline
   font-weight="bold">
   <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="br">
  <fo:block>
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="ref">
  <xsl:choose>
   <xsl:when test="@url">
    <xsl:choose>
     <xsl:when test="@lang = 'de' or @lang = 'en'">
      <fo:external-graphic>
       <xsl:attribute name="src">file:///<xsl:value-of select="$img_dir"/>/<xsl:value-of select="@lang"/>.png</xsl:attribute>
      </fo:external-graphic>
      <xsl:text>&#160;</xsl:text>
     </xsl:when>
    </xsl:choose>
    <fo:inline
     color="rgb(51, 51, 255)"
     text-decoration="underline">
     <fo:basic-link>
      <xsl:attribute name="external-destination">
       <xsl:value-of select="@url"/>
      </xsl:attribute>
      <xsl:apply-templates/>
     </fo:basic-link>
    </fo:inline>
   </xsl:when>
   <xsl:when test="@chapter">
    <fo:inline
     color="rgb(51, 51, 255)">
     <xsl:apply-templates/>
    </fo:inline>
   </xsl:when>
   <xsl:when test="@iref">
    <fo:external-graphic>
     <xsl:attribute name="src">file:///<xsl:value-of select="$img_dir"/>/intern.png</xsl:attribute>
    </fo:external-graphic>
    <xsl:text>&#160;</xsl:text>
    <fo:inline
     color="rgb(51, 51, 255)">
     <fo:basic-link>
      <xsl:attribute name="internal-destination">
       <xsl:value-of select="@iref"/>
      </xsl:attribute>
      <xsl:apply-templates/>
     </fo:basic-link>
    </fo:inline>
   </xsl:when>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="quotation">
  <fo:block
   font-family="serif"
   font-size="10pt"
   text-align="justify"
   space-before="5pt"
   space-after="5pt"
   start-indent="2em">
   <xsl:apply-templates/>
  </fo:block>
 </xsl:template>

 <xsl:template match="italic">
  <fo:inline
    font-style="italic">
    <xsl:apply-templates/>
  </fo:inline>
 </xsl:template>

 <xsl:template match="version">
  <xsl:value-of select="$version"/>
 </xsl:template>

</xsl:stylesheet>
