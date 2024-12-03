<?xml version="1.0" encoding="utf-8" ?>

<!-- xslt zum einlesen von rechnungspositonen (lineitems) in filemaker

autor: jens teich (info@jensteich.de)
v 0.1 2024-11-28

ich gehe davon aus, dass du mit Claris FileMaker (dies sind eingetragene Marken von
Claris International, Inc.), aber nicht mit xslt vertraut bist.

daher (immer wieder gerne) der wichtige hinweis: wer dies dokument veraendern moechte,
der/die darf das natuerlich.  Aber er/sie waehle mit bedacht das werkzeug (den texteditor) hierfuer.
MS Word et al. sind textverarbeitungen und ungeeignet.  wir brauchen den nackten text.
ich verwende Emacs, der fuer den einsteiger nicht ganz einfach zu bedienen ist.

zweiter hinweis: der verwendete texteditor sollte xml-aware sein, d.h. er sollte wissen,
dass innerhalb von xml (und auch das xslt ist xml) tags vorkommen (so etwas wie
<MY_TAG>blah blah blubb</MY_TAG>), dass diese gewissen Regeln unterliegen, z.b.
wie klammern immer artig ineinander verschachtelt sind und er sollte entsprechend
fehler anzeigen, wenn du anderes probierst.

einige vorschlaege fuer xml texteditoren findest du hier:
https://www.w3schools.io/file/xml-editor/
-->

<!-- das attribut version="1.0" des stylesheets zeigt uns, dass wir mit FileMaker
     noch in der computer-steinzeit festhaengen (https://www.w3.org/TR/xslt-10/):
     1999! laengst ist version="2.0" erschienen (https://www.w3.org/TR/xslt20/): 2009
     und zweite Ausgabe 2021 und version="3.0" 2017.

     dann folgen einige namespace definitionen: xsl, cac und cbc werden als
     Abkuerzungen der jeweils dahinter folgenden (und etwas laenglichen) uri's
     eingefuehrt.  einer von ihnen (der default namespace) darf auf eine abkuerzung verzichten. hier
     waehlen wir schlau '...filemaker.com/fmpxmlresult', so dass alle ausdruecke, die im folgenden
     kein kuerzel und keinen doppelpunkt enthalten, dem von Claris/FileMaker definierten
     namespace und damit der grammatik fmpxmlresult
     (https://help.claris.com/de/pro-help/content/xml-format.html)
     zugerechnet werden.

     Also sind die elemente FIELD, ROW, COL, DATA, ... von Claris FileMaker
     festgelegt, waehrend 'xsl:stylesheet', 'xsl:template', 'xsl:value-of', ... zur grundausstattung
     des xslt gehoeren und 'cac:...' und 'cbc:...' auf indsustrie standards verweisen.
-->

<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.filemaker.com/fmpxmlresult"
    
    xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"
    xmlns:ccts="urn:un:unece:uncefact:documentation:2"
    xmlns:qdt="urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2"
    xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"
    xmlns:inv="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">

<!-- Hier wird die erste vorlage (xsl:template) definiert und erinnert
     uns daran, dass die xslt verarbeitung etwas anders ist, als wir
     das z.b. von FileMaker scripts kennen.  einfach gesagt geht es
     nicht zeile fuer zeile durch den code, sondern es koennen im xslt
     vorlagen mit xpath (<xsl:template match="/hier/kommt/der/xpath">)
     verknuepft werden, die dann im xml gesucht werden.

     als beispiel findet sich hier eine xsl:template, die mit dem
     einfachsten denkbaren xpath ausdruck naemlich '/' verbunden wird.
     Dies findet genau die wurzel (root) des xml.  es kann hiervon nur
     eine geben. dies ist daher ein guter ort, um das gesamte geruest
     eines fmpxmlresult xml (also eines Dokumentes mit xml grammatik,
     welches fuer Claris FileMaker verdaulich ist.)

     sehr foerderlich dem weiteren verstaendnis ist (falls noch nicht
     geschehen), eine leere, neue FM DB zu erstellen, dort 2-3 felder
     anzulegen und diese mit einigen testdaten zu befuellen.  dann den
     umgekehrten weg einschlagen und exportieren (per script oder ueber
     das menue file/export_records) um ein text dokument zu erhalten,
     welches die von Claris/FM vorgeschlagene Grammatik illustriert.
     dabei waehlt ihr die grammatik fmpxmlresult und KEIN xslt.

     Die Firma Claris hat sich entschieden, beim export die
     platzsparende variante ohne zeilenschaege und einrueckungen zu
     verwenden.  dies macht auch fuer den produktiven betrieb viel
     sinn, hindert uns aber in diesem moment, die struktur zu
     erkennen.  also ist etwas handarbeit gefragt, oder ihr ersetzt
     '<' durch '¶<', was vermutlich nur eine FM entwicklerin versteht.

     weitere dokumentation zu xpath findet sich zahlreich, z.b.:
     https://developer.mozilla.org/en-US/docs/Web/XPath.  die original
     quelle ist verlinkt auf: https://www.w3.org/TR/xpath/.
  -->
  
  <xsl:template match="/">
    <FMPXMLRESULT>

      <ERRORCODE>0</ERRORCODE>
      <PRODUCT BUILD="" NAME="" VERSION=""/>
      <DATABASE DATEFORMAT="" LAYOUT="" NAME="" RECORDS="" TIMEFORMAT=""/>

      <METADATA>

	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemID" TYPE="TEXT"/>
	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemNote" TYPE="TEXT"/>
	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemInvoicedQuantiy" TYPE="TEXT"/>
	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemInvoicedQuantiyUnitCode" TYPE="TEXT"/>
	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemInvoicedQuantiyUnitCodeListID" TYPE="TEXT"/>
	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemLineExtensionAmount" TYPE="TEXT"/>
	<FIELD EMPTYOK="YES" MAXREPEAT="1" NAME="LineItemLineExtensionAmountCurrencyID" TYPE="TEXT"/>

        <!-- hier ist die erste von zwei stellen, an denen ihr taetig
             werden duerft, so ihr ein weiteres Feld in FM befuellen
             wollt.  Die bereits definierte namensliste (von
             LineItemID bis lineitemlineextensionamountcurrencyid legt
             sieben namen fest, welche im fm dialog beim import
             erscheinen.  das glaubt oder versteht ihr nicht?  dann
             probiert es doch selber!

             veraendert einen namen und importiert mit xslt.  dann
             solltet ihr euren frei gewaehlten namen wiederfinden.  in
             dem riesigen import dialag, der die feldfolge definiert.

             dies xslt ist in der lage, sieben felder zu befuellen oder
             auch neu zu erzeugen.  und wenn ihr nun ein weiteres feld
             befuellen oder erzeugen wollt?  na klar, dann braucht ihr
             eine weitere zeile, die beginnt mit '<field' und im
             weiteren verlauf den jeweils gewuenschten namen im
             attribut name="hier_kommt_der_neue_name" benennt.

             schlaufuechse verwenden hier die bereits in fm vorhandenen
             feldnamen, so solche existieren.  dann werden die im xml
             gefundenen daten mit der (fm-import) option 'matching
             names' bzw. 'passende namen' (?) automatisch in die
             richtigen felder einsortiert.
        -->

      </METADATA>

      <RESULTSET FOUND="">

        <!-- die hier folgende zeile setzt den mechanismus fort, der
             weitere passende vorlagen sucht.  an dieser stelle
             (innerhalb des von fm erdachten resultset) erwarten wir
             doch ungemein ein oder mehrere row elemente, die in der
             fmpxmlresult grammatik ja den datensatz darstellen.  -->
        
	<xsl:apply-templates/>

      </RESULTSET>

    </FMPXMLRESULT>
  </xsl:template>


  <!-- und hier kommt sie schon: die vorlage fuer den fm datensatz.  im
       xml wird sie gefunden durch cac:invoiceitem
  -->

  <xsl:template match="cac:InvoiceLine">

    <!-- hier innerhalb der vorlage sagt ROW, dass FM jetzt einen neuen datensatz erhaelt.  -->
    
    <ROW MODID="" RECORDID="">

      <!-- die sieben COL zeilen gehoeren zu den sieben oben definierten FIELDS.
           und zwar in genau der gleichen reihenfolge wie oben. -->

      <!-- wo sind wir gerade im xml dokument? ach ja, an der stelle
           cac:invoiceLine.  genau dort, dh. innerhalb des
           cac:invoiceLine aber als direktes Kind sucht es eine cbc:ID
           ...  -->
      <COL><DATA><xsl:value-of select="cbc:ID"/></DATA></COL>

      <!-- ... und eine cbc:Note ... -->
      <COL><DATA><xsl:value-of select="cbc:Note"/></DATA></COL>

      <!-- ... und eine cbc:InvoicedQuantity ... -->
      <COL><DATA><xsl:value-of select="cbc:InvoicedQuantity"/></DATA></COL>

      <!-- ... und in der cbc:InvoicedQuantity ein Attribut unitCode usw, usw.-->
      <COL><DATA><xsl:value-of select="cbc:InvoicedQuantity/@unitCode"/></DATA></COL>
      <COL><DATA><xsl:value-of select="cbc:InvoicedQuantity/@unitCodeListID"/></DATA></COL>
      <COL><DATA><xsl:value-of select="cbc:LineExtensionAmount"/></DATA></COL>
      <COL><DATA><xsl:value-of select="cbc:LineExtensionAmountCurrencyID"/></DATA></COL>
      <!-- und weitere zeilen nach dem vorbild der vorigen sieben
           werden benoetigt, um neue felder zu erreichen -->
    </ROW>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:stylesheet>
