<?xml version="1.0" encoding="ISO-8859-1"?>

<!--
 * format.xsl - Templates für die allemeinen Textformatierungen
 * Copyright Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.20 $
 * $Source: /selflinux/stylesheets/html/format.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.org
 *
 *** $Id: format.xsl,v 1.20 2004/04/09 16:12:43 florian Exp $
-->

<xsl:stylesheet version="1.0"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:saxon="http://icl.com/saxon"
 extension-element-prefixes="saxon">

 <!--
  Hier werden die Vorlagen für die einfachen Textformatierungen
  definiert.
 -->

 <!--
  ref-Template
  dient zum Setzen von Links auf andere SelfLinux-Kapitel und Webseiten.

  Das ref-Element wird genauso wie ein a-Tag verwendet.
  Um externe Links zu setzen, wird das url-Attribut verwendet (Sprachangabe
  im lang-Attribut).
  Für interne Links wird der index-Name eines anderen Kapitels über das
  chapter-Attribut, der Titel des genauen Kapitels mit dem iref-Attribut
  angegeben.
 -->
 
 <xsl:template match="ref">
  <xsl:variable name="img_dir">
   <xsl:if test="not(//selflinux)">
    <xsl:text>../</xsl:text>
   </xsl:if>
   <xsl:text>bilder</xsl:text>
  </xsl:variable>
  <xsl:choose>
   <xsl:when test="@url">
    <xsl:choose>
     <xsl:when test="@lang = 'de' or @lang = 'en'">
      <img width="16" height="10">
       <xsl:attribute name="alt">
        <xsl:value-of select="@lang"/>
       </xsl:attribute>
       <xsl:attribute name="src">
        <xsl:value-of select="$img_dir"/>
        <xsl:text>/</xsl:text>
        <xsl:value-of select="@lang"/>
        <xsl:text>.png</xsl:text>
       </xsl:attribute>
      </img>
      <xsl:text>&#160;</xsl:text>
     </xsl:when>
    </xsl:choose>
    <a target="_blank">
     <xsl:attribute name="href">
      <xsl:value-of select="normalize-space(@url)"/>
     </xsl:attribute>
     <xsl:apply-templates/>
    </a>
   </xsl:when>
   <xsl:when test="@iref | @chapter">
    <xsl:variable name="iref"><xsl:value-of select="normalize-space(@iref)"/></xsl:variable>
    <xsl:variable name="chapter"><xsl:value-of select="normalize-space(@chapter)"/></xsl:variable>
    <xsl:choose>
     <xsl:when test="not(@chapter) and not(//section[normalize-space(heading)=$iref]|//textblock[normalize-space(@name) = $iref])">
      <xsl:message terminate="no">
       <xsl:value-of select="saxon:systemId()"/>:<xsl:value-of select="saxon:line-number()"/>
WARNUNG: Kein Referenzziel gefunden!
      </xsl:message>
     </xsl:when>
     <xsl:when test="@chapter and $index='none'">
      <xsl:message terminate="no">
       <xsl:value-of select="saxon:systemId()"/>:<xsl:value-of select="saxon:line-number()"/>
WARNUNG: Ignoriere Iref auf anderes SelfLinux-Kapitel. (Kein Index verwendet)
      </xsl:message>
     </xsl:when>
     <xsl:when test="@chapter and (not(document($index)//chapter[@index=$chapter]) or (@iref and not(document($index)//chapter[@index=$chapter]//*[@name=$iref])))">
      <xsl:message terminate="no">
       <xsl:value-of select="saxon:systemId()"/>:<xsl:value-of select="saxon:line-number()"/>
WARNUNG: Referenzziel (<xsl:value-of select="@chapter"/>/<xsl:value-of select="@iref"/>) nicht gefunden!
      </xsl:message>
     </xsl:when>
    </xsl:choose>
    <img width="10" height="10" alt="">
     <xsl:attribute name="src">
      <xsl:value-of select="$img_dir"/>
      <xsl:text>/intern.png</xsl:text>
     </xsl:attribute>
    </img>
    <xsl:text>&#160;</xsl:text>
    <a>
     <xsl:attribute name="href">
      <xsl:choose>
       <xsl:when test="not(@chapter)">
        <xsl:apply-templates mode="ref" select="//section[normalize-space(heading) = $iref]|//textblock[normalize-space(@name) = $iref]"/>
       </xsl:when>
       <xsl:when test="$index!='none' and @chapter and not(@iref)">
        <xsl:apply-templates mode="refindex" select="document($index)//chapter[@index=$chapter]"/>
       </xsl:when>
       <xsl:when test="$index!='none' and @chapter and @iref">
        <xsl:apply-templates mode="refindex" select="document($index)//chapter[@index=$chapter]//*[@name=$iref]"/>
       </xsl:when>
      </xsl:choose>
     </xsl:attribute>
     <xsl:apply-templates/>
    </a>
   </xsl:when>
   <xsl:otherwise>
    <xsl:message terminate="yes">
     <xsl:value-of select="saxon:systemId()"/>:<xsl:value-of select="saxon:line-number()"/>
FEHLER: Keine gültiges Referenzziel angegeben!
    </xsl:message>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  keyword-Template
  Keywords werden bereits eigens behandelt. Ins eigentliche Dokument
  sollen sie aber nicht eingefügt werden.
 -->

 <xsl:template match="keyword">
 </xsl:template>

 <!--
  keycomb-Template
  Mit dem keycomb-Template können Tastenkombinationen eingegeben werdne.

  Sind die Tasten nacheinander zu drücken, so werden sie mit "," getrennt,
  falls sie gleichzeitig gedrückt werden müssen, wird ein "+" zwischen sie
  gezeichnet.
 -->
 
 <xsl:template match="keycomb">
  <xsl:choose>
   <xsl:when test="@mode='sequence'">
    <xsl:for-each select="key">
     <tt>
      <xsl:value-of select="."/>
      <xsl:if test="following-sibling::key">,</xsl:if>
     </tt>
    </xsl:for-each>
   </xsl:when>
   <xsl:otherwise>
    <xsl:for-each select="key">
     <tt>
      <xsl:value-of select="."/>
      <xsl:if test="following-sibling::key">+</xsl:if>
     </tt>
    </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  command-Template
  Kommandos werden mit courier und in einer anderen Farbe dargestellt.
 -->
 
 <xsl:template match="command">
  <font face="courier" color="#aa5522">
   <xsl:apply-templates/>
  </font>
 </xsl:template>

 <!--
  path-Template
  Pfadangaben werden ebenfalls in courier und anderer Farbe dargestellt.
 -->
 
 <xsl:template match="path">
  <font face="courier" color="#277717">
   <xsl:apply-templates/>
  </font>
 </xsl:template>

 <!--
  name-Template
  Dieses Template erzeugt einen Link auf einen Namen evtl. mit EMail-Adresse
 -->
 
 <xsl:template match="name">
  <xsl:choose>
   <xsl:when test="@email">
    <em>
     <xsl:apply-templates/>
    </em>
    <xsl:text> (&#160;</xsl:text>
    <img width="16" height="10" alt="">
     <xsl:attribute name="src">
      <xsl:choose>
       <xsl:when test="//selflinux">
        <xsl:text>bilder/email.png</xsl:text>
       </xsl:when>
       <xsl:otherwise>
        <xsl:text>../bilder/email.png</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>
    </img>
    <xsl:text>&#160;</xsl:text>
    <a href="mailto:{@email}">
     <xsl:value-of select="@email"/>
    </a>
    <xsl:text>)</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <em>
     <xsl:apply-templates/>
    </em>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--
  version-Template
  Das Version-Template fügt die aktuelle Versionsnummer von Selflinux ein.
 -->
 
 <xsl:template match="version">
  <xsl:value-of select="$version"/>
 </xsl:template>

 <!-- 
  Die folgenden Tags haben in SelfLinux die gleiche Funktion wie in HTML.
  Sie werden (bis auf kleine Einschränkungen) direkt in die Ausgabe 
  übernommen.
 -->
 
 <xsl:template match="ul">
  <ul>
   <xsl:apply-templates/>
  </ul>
 </xsl:template>

 <xsl:template match="ol">
  <ol>
   <xsl:apply-templates/>
  </ol>
 </xsl:template>

 <xsl:template match="li">
  <li>
   <xsl:apply-templates/>
  </li>
 </xsl:template>

 <xsl:template match="strong">
  <strong>
   <xsl:apply-templates/>
  </strong>
 </xsl:template>

 <xsl:template match="italic">
  <em>
   <xsl:apply-templates/>
  </em>
 </xsl:template>

 <xsl:template match="sub|sup">
  <xsl:copy>
   <xsl:apply-templates/>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="br">
  <br/>
 </xsl:template>

 <xsl:template match="table">
  <table>
   <xsl:attribute name="border">
    <xsl:choose>
     <xsl:when test="@border">
      <xsl:value-of select="@border"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>0</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <xsl:attribute name="cellspacing">
    <xsl:choose>
     <xsl:when test="@cellspacing">
      <xsl:value-of select="@cellspacing"/>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>5</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <xsl:for-each select="tr">
    <tr>
     <xsl:for-each select="th">
      <th>
       <xsl:attribute name="valign">
        <xsl:choose>
         <xsl:when test="@valign">
          <xsl:value-of select="@valign"/>
         </xsl:when>
         <xsl:otherwise>
          <xsl:text>top</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:attribute>
       <xsl:for-each select="@align|@rowspan|@colspan|@nowrap">
        <xsl:copy/>
       </xsl:for-each>
       <xsl:apply-templates select="*|text()"/>
      </th>
     </xsl:for-each>
     <xsl:for-each select="td">
      <td>
       <xsl:attribute name="valign">
        <xsl:choose>
         <xsl:when test="@valign">
          <xsl:value-of select="@valign"/>
         </xsl:when>
         <xsl:otherwise>
          <xsl:text>top</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:attribute>
       <xsl:for-each select="@align|@rowspan|@colspan|@nowrap">
        <xsl:copy/>
       </xsl:for-each>
       <xsl:apply-templates select="*|text()"/>
      </td>
     </xsl:for-each>
    </tr>
   </xsl:for-each>
  </table>
 </xsl:template>

</xsl:stylesheet>
