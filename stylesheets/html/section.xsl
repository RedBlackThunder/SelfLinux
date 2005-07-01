<?xml version="1.0" encoding="ISO-8859-1"?>
 
<!--
 * section.xsl - Templates für das Parsen eines Kapitels
 * Copyright Peter Schneewind, Johannes Kolb
 * diverse Erweiterungen: Florian Frank, Rolf Brunsendorf
 *
 * $Revision: 1.14 $
 * $Source: /selflinux/stylesheets/html/section.xsl,v $
 *
 * Diese Datei ist Teil von SelfLinux  http://www.selflinux.de
 *
 *** $Id: section.xsl,v 1.14 2004/05/25 21:11:00 florian Exp $
-->
 
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:saxon="http://icl.com/saxon"
                extension-element-prefixes="saxon">

 
<!--
 Vorlage zur Ausgabe der "section"-Elemente.
 Die XPath-Funktion "generate-id()" liefert eine eindeutige ID, hier 
 fuer das Element "section". Wird die Funktion an anderer Stelle der
 Transformation auf dasselbe Element angewendet, liefert sie auch
 dort dieselbe eindeutige ID.
-->
<xsl:template match="section">
 <xsl:variable name="section_nr"><xsl:number level="any"/></xsl:variable>
 <xsl:variable name="section_name"><xsl:value-of select="normalize-space(heading)"/></xsl:variable>
 <xsl:variable name="new_character"><xsl:text> </xsl:text></xsl:variable>

 <xsl:choose>
  <xsl:when test="$silent = 'false'">
   <xsl:message>		chapter: <xsl:value-of select="concat($section_nr,$new_character,$section_name)"/>
   </xsl:message>
  </xsl:when>
 </xsl:choose>
 <br/>
 <table>
  <tr>
   <td>
    <h4>
     <a>
      <xsl:attribute name="name">
       <xsl:choose>
        <xsl:when test="$index='none'">
	 <xsl:value-of select="generate-id()"/>
	</xsl:when>
	<xsl:otherwise>
	 <xsl:value-of select="document($index)//chapter[@index=$chapter_index]/descendant::section[position()=$section_nr]/@id"/>
	</xsl:otherwise>
       </xsl:choose>
      </xsl:attribute>
      <xsl:number format="1" count="split/section" level="any"/>
      <xsl:if test="parent::section">
       <xsl:number format=".1 " count="section/section" level="multiple"/>
      </xsl:if>
      <xsl:text> </xsl:text>
      <xsl:value-of select="heading"/>
     </a>
    </h4>
    <xsl:apply-templates/>
   </td>
  </tr>
 </table>
</xsl:template>

<xsl:template match="heading"/>

<!--
 Vorlage fuer Elemente vom Typ "textblock".
 Es werden alle Child-Elemente verarbeitet, fuer die eine passende Vorlage
 existiert.
-->
<xsl:template match="textblock">
 <p>
  <xsl:if test="@name">
   <a>
    <xsl:attribute name="name">
     <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
   </a>
  </xsl:if> <!-- @name -->
  <xsl:apply-templates/>
 </p>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "definition"
-->
<xsl:template match="definition">
 <table cellpadding="5" class="definition">
  <tr>
   <td>
    <xsl:apply-templates/>
   </td>
  </tr>
 </table>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "quotation"
 -->
<xsl:template match="quotation">
 <blockquote>
  <xsl:apply-templates/>
 </blockquote>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "hint"
-->
<xsl:template match="hint">
 <table cellpadding="5" class="hint">
  <tr>
   <td>
    <xsl:apply-templates/>
   </td>
  </tr>
 </table>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "image"
-->
<xsl:template match="image">
 <table width="100%">
  <tr>
   <td align="center">
    <img>
     <xsl:attribute name="src" saxon:disable-output-escaping="yes">
      <xsl:value-of select="normalize-space($img_dir)"/>
      <xsl:text>/</xsl:text>
      <xsl:value-of select="normalize-space($index_file)"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="normalize-space(filename)"/>
     </xsl:attribute>
     <xsl:attribute name="alt">
      <xsl:value-of select="alt|title"/>
     </xsl:attribute>
    </img>
   </td>
  </tr>
  <xsl:if test="title">
   <tr>
    <td align="center">
     <small>
      <xsl:value-of select="title"/>
     </small>
     <br/>
    </td>
   </tr>
  </xsl:if>
 </table>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "file"
 changed: STD: pre in der gleichen Zeile wie select="content"
-->
<xsl:template match="file">
 <table width="100%" border="border" cellpadding="10">
  <xsl:if test="title">
   <tr>
    <td align="center">
     <xsl:value-of select="title"/>
    </td>
   </tr>
  </xsl:if>
  <tr>
   <td bgcolor="#fffdc4">
    <pre><xsl:value-of select="content"/></pre>
   </td>
  </tr>
 </table>
</xsl:template>



<!-- Based on: http://www.biglist.com/lists/xsl-list/archives/200009/msg00991.html -->
<!-- Extended with br-replace-except-first and sp-replace-no-tailings -->

<!-- UtilText.xsl: Common text formatting routines -->
<!-- xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" -->

<!-- Replace new lines, except the very first and last, with html <br> tags -->
<xsl:template name="br-replace-except-first">
 <xsl:param name="text"/>
 <xsl:variable name="cr" select="'&#xa;'"/>

 <xsl:choose>
  <!-- If the value of the $text parameter contains a carriage return... -->
  <xsl:when test="contains($text,$cr)">
   <!-- Return the substring of $text before the carriage return -->
   <xsl:value-of select="substring-before($text,$cr)"/>
   <!-- don't construct the very first br - just throw away \n -->
   <!--
    | Then invoke this same br-replace template again, passing the
    | substring *after* the carriage return as the new "$text" to
    | consider for replacement
    +-->
   <xsl:call-template name="br-replace">
    <xsl:with-param name="text" select="substring-after($text,$cr)"/>
   </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$text"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Replace new lines, except the very last, with html <br> tags -->
<xsl:template name="br-replace">
 <xsl:param name="text"/>
 <xsl:variable name="cr" select="'&#xa;'"/>

 <xsl:choose>
  <!-- If the value of the $text parameter contains a carriage return... -->
  <xsl:when test="contains($text,$cr)">
   <!-- Return the substring of $text before the carriage return -->
   <xsl:value-of select="substring-before($text,$cr)"/>
   <xsl:if test="translate(substring-after($text,$cr),' &#09;','')">
    <!-- And construct a <br/> element -->
    <br/>
    <!--
    | Then invoke this same br-replace template again, passing the
    | substring *after* the carriage return as the new "$text" to
    | consider for replacement
    +-->
    <xsl:call-template name="br-replace">
     <xsl:with-param name="text" select="substring-after($text,$cr)"/>
    </xsl:call-template>
   </xsl:if>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$text"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Replace two consecutive spaces w/ 2 non-breaking spaces, except trailings-->
<xsl:template name="sp-replace-no-tailings">
 <xsl:param name="text"/>
 <!-- NOTE: There are two spaces   ** here below -->
 <xsl:variable name="sp"><xsl:text>  </xsl:text></xsl:variable>

 <xsl:choose>
  <xsl:when test="contains($text,$sp)">
   <xsl:value-of select="substring-before($text,$sp)"/>
   <xsl:choose>
    <xsl:when test="translate(substring-after($text,$sp),' ','')">
     <xsl:text>&#160;&#160;</xsl:text>
     <xsl:call-template name="sp-replace-no-tailings">
      <xsl:with-param name="text" select="substring-after($text,$sp)"/>
     </xsl:call-template>
    </xsl:when>
   </xsl:choose>
  </xsl:when>
  <xsl:otherwise>
   <xsl:if test="translate($text,' ','')">
    <xsl:value-of select="$text"/>
   </xsl:if>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- Replace two consecutive spaces w/ 2 non-breaking spaces -->
<xsl:template name="sp-replace">
 <xsl:param name="text"/>
 <!-- NOTE: There are two spaces   ** here below -->
 <xsl:variable name="sp"><xsl:text>  </xsl:text></xsl:variable>

 <xsl:choose>
  <xsl:when test="contains($text,$sp)">
   <xsl:value-of select="substring-before($text,$sp)"/>
   <xsl:text>&#160;&#160;</xsl:text>
   <xsl:call-template name="sp-replace">
    <xsl:with-param name="text" select="substring-after($text,$sp)"/>
   </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$text"/>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>
<!-- end UtilText.xsl: Common text formatting routines -->

<!--
 Vorlage fuer Elemente vom Typ "shell"
-->
<xsl:template match="shell">
 <table align="center" width="90%" border="2" cellspacing="4" cellpadding="5">
  <tr>
   <td>
    <font face="courier,monospace">
     <xsl:apply-templates/>
    </font>
   </td>
  </tr>
 </table>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "shell/user".
-->
<xsl:template match="shell/user">
 <xsl:variable name="username">
  <xsl:choose>
   <xsl:when test="@name">
    <xsl:value-of select="@name"/>
   </xsl:when>
   <xsl:when test="preceding-sibling::user[@name]">
    <xsl:value-of select="preceding-sibling::user[@name][position()=1]/@name"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>user</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>

 <xsl:if test="preceding-sibling::*[1][self::output]">
  <br/>
 </xsl:if>
 <font color="#0000AA">
  <xsl:value-of select="$username"/>
  <xsl:text>@linux </xsl:text>
  <xsl:choose>
   <xsl:when test="@path">
    <xsl:value-of select="@path"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="preceding-sibling::*[self::user|self::root][@path][position()=1]/@path"/>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:text>$ </xsl:text>
 </font>
 <font color="#3333FF">
  <xsl:value-of select="."/>
 </font>
 <br/>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "shell/root"
-->
<xsl:template match="shell/root">
 <xsl:if test="preceding-sibling::*[1][self::output]">
  <br/>
 </xsl:if>
 <font color="#AA0000">
  <xsl:text>root@linux </xsl:text>
  <xsl:choose>
   <xsl:when test="@path">
    <xsl:value-of select="@path"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="preceding-sibling::*[self::root|self::user][@path][position()=1]/@path"/>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:text># </xsl:text>
 </font>
 <font color="#3333FF">
  <xsl:value-of select="."/>
 </font>
 <br/>
</xsl:template>


<!--
 Vorlage fuer Elemente vom Typ "shell/output" (die Zeile nach dem Prompt")
-->
<xsl:template match="shell/output2">
 <font face="courier">
  <xsl:value-of select="."/>
 </font>
</xsl:template>

<!-- added by steffen. This emulates a special PRE tag -->
<xsl:template match="shell/output">
 <xsl:if test="preceding-sibling::*[1][self::output]">
  <br/>
 </xsl:if>
 <xsl:call-template name="br-replace-except-first">
  <xsl:with-param name="text">
   <xsl:call-template name="sp-replace-no-tailings">
    <xsl:with-param name="text" select="."/>
   </xsl:call-template>
  </xsl:with-param>
 </xsl:call-template>
</xsl:template>


<xsl:template match="shell/input2">
 <font color="#3333FF">
  <xsl:value-of select="."/>
 </font>
</xsl:template>

<!-- added by steffen. This emulates a special PRE tag -->
<xsl:template match="shell/input">
 <font color="#3333FF">
  <xsl:call-template name="br-replace-except-first">
   <xsl:with-param name="text">
    <xsl:call-template name="sp-replace-no-tailings">
     <xsl:with-param name="text" select="."/>
    </xsl:call-template>
   </xsl:with-param>
  </xsl:call-template>
  <br/>  
 </font>
</xsl:template>

</xsl:stylesheet>
