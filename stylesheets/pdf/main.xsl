<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format"
 xmlns:fox="http://xml.apache.org/fop/extensions">

 <xsl:output method="xml" encoding="ISO-8859-1"/>

 <xsl:param name="version"/>
 <xsl:param name="img_dir"/>

 <xsl:template match="chapter">
  <fo:root>
   <fox:outline internal-destination="START">
    <fox:label>
     <xsl:value-of select="normalize-space(/chapter/title)"/>
    </fox:label>
   </fox:outline>
   <xsl:if test="count(//split/section) > 1">
    <fox:outline internal-destination="Inhaltsverzeichnis">
     <fox:label>Inhaltsverzeichnis</fox:label>
    </fox:outline>
   </xsl:if>
   <xsl:apply-templates select="split/section" mode="bookmark"/>
   <fo:layout-master-set>
    <fo:simple-page-master
     master-name="title"
     page-height="29.7cm"
     page-width="21cm"
     margin-top="2.5cm"
     margin-bottom="2.5cm"
     margin-left="2.5cm"
     margin-right="2.5cm">
     <fo:region-body/>
    </fo:simple-page-master>

    <fo:simple-page-master
     master-name="text"
     page-height="29.7cm"
     page-width="21cm"
     margin-top="2.5cm"
     margin-bottom="2.5cm"
     margin-left="2.5cm"
     margin-right="2.5cm">
     <fo:region-body
      margin-top="2cm"
      margin-bottom="2cm"/>
     <fo:region-before region-name="header" extent="2cm"/>
     <fo:region-after region-name="footer" extent="2cm"/>
    </fo:simple-page-master>

    <fo:page-sequence-master master-name="document">
     <fo:repeatable-page-master-alternatives>
      <fo:conditional-page-master-reference
       page-position="first"
       master-reference="title"/>
      <fo:conditional-page-master-reference
       page-position="rest"
       master-reference="text"/>
     </fo:repeatable-page-master-alternatives>
    </fo:page-sequence-master>
   </fo:layout-master-set>

   <fo:page-sequence
    master-reference="document"
    force-page-count="no-force">
    <fo:static-content flow-name="header">
     <fo:table table-layout="fixed" width="100%">
      <fo:table-column column-width="proportional-column-width(3)"/>
      <fo:table-column column-width="proportional-column-width(1)"/>
      <fo:table-body>
       <fo:table-row>
        <fo:table-cell>
         <fo:block text-align="left">
          <xsl:apply-templates
           select="title"
           mode="header"/>
         </fo:block>
        </fo:table-cell>
        <fo:table-cell>
         <fo:block
          font-family="serif"
          font-size="12pt"
          font-weight="bold"
          text-align="right">
          <xsl:text>Seite </xsl:text>
          <fo:page-number/>
         </fo:block>
        </fo:table-cell>
       </fo:table-row>
      </fo:table-body>
     </fo:table>
     <fo:block>
      <fo:leader
       leader-length="100%"
       leader-pattern="rule"
       rule-thickness="1pt"
       color="black"/>
     </fo:block>
    </fo:static-content>

    <fo:static-content flow-name="footer">
     <fo:block>
      <fo:leader
       leader-length="100%"
       leader-pattern="rule"
       rule-thickness="1pt"
       color="black"/>
     </fo:block>
     <fo:table table-layout="fixed" width="100%">
      <fo:table-column column-width="proportional-column-width(1)"/>
      <fo:table-body>
       <fo:table-row>
        <fo:table-cell>
         <fo:block
          text-align="center"
          font-family="serif"
          font-size="12pt"
          font-weight="bold">
          <xsl:value-of select="$version"/>
         </fo:block>
        </fo:table-cell>
       </fo:table-row>
      </fo:table-body>
     </fo:table>
    </fo:static-content>

    <fo:flow flow-name="xsl-region-body">

     <fo:block id="START">
      <fo:table table-layout="fixed" width="100%">
       <fo:table-column column-width="proportional-column-width(1)"/>
       <fo:table-body>
        <fo:table-row height="29.7cm">
         <fo:table-cell display-align="center">
          <fo:block text-align="center" font-size="20pt">
           <xsl:value-of select="$version"/>
          </fo:block>
          <fo:block text-align="center" space-before="50pt">
           <fo:external-graphic>
            <xsl:attribute name="src">file:///<xsl:value-of select="$img_dir"/>/selflinux.png</xsl:attribute>
           </fo:external-graphic>
          </fo:block>
          <fo:block text-align="center" space-before="50pt">
           <xsl:apply-templates select="title"/>
          </fo:block>
          <fo:block text-align="center" space-before="25pt">
           <fo:external-graphic>
            <xsl:attribute name="src">file:///<xsl:value-of select="$img_dir"/>/document.png</xsl:attribute>
           </fo:external-graphic>
          </fo:block>
          <fo:block text-align="center" space-before="25pt">
           <xsl:apply-templates select="author"/>
           <xsl:apply-templates select="layout"/>
           <xsl:apply-templates select="license"/>
          </fo:block>
          <fo:block text-align="justify" space-before="50pt">
           <xsl:apply-templates select="description"/>
          </fo:block>
         </fo:table-cell>
        </fo:table-row>
       </fo:table-body>
      </fo:table>
     </fo:block>

     <xsl:if test="count(//split/section) > 1">
      <fo:block break-before="page">
       <fo:block
        font-family="serif"
        font-size="16pt"
        font-weight="bold"
        space-after="10pt"
        id="Inhaltsverzeichnis">
        <xsl:text>Inhaltsverzeichnis</xsl:text>
       </fo:block>
       <fo:block>
        <xsl:apply-templates select="split/section" mode="toc"/>
       </fo:block>
      </fo:block>
     </xsl:if>

     <fo:block>
      <xsl:apply-templates select="split"/>
     </fo:block>

    </fo:flow>
   </fo:page-sequence>
  </fo:root>
 </xsl:template>

 <xsl:include href="common.xsl"/>
 <xsl:include href="chapter.xsl"/>
 <xsl:include href="section.xsl"/>
 <xsl:include href="shell.xsl"/>
 <xsl:include href="lists.xsl"/>
 <xsl:include href="image.xsl"/>
 <xsl:include href="table.xsl"/>
 <xsl:include href="file.xsl"/>

</xsl:stylesheet>
