import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/providers/providers.dart';

class TerminosCondiciones extends StatelessWidget {
  const TerminosCondiciones({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Text(
            'Responsable',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.start,
          ),
          Text(
            loginService.userDataLogged.persNombres!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(
            height: 10,
          ),
          _TerminosCondiciones(),
          ListTile(
            minVerticalPadding: 0,
            minLeadingWidth: 0,
            title: const Text('¿Acepta términos y condiciones?'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Si'),
                      activeColor: Colors.green,
                      value: 'SI',
                      groupValue: inspeccionProvider.aceptaTerminos.toString(),
                      onChanged: (value) async {
                        inspeccionProvider.updateTerminos(value.toString());
                        Navigator.pushNamed(context, 'create_signature');
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('No'),
                      activeColor: Colors.green,
                      value: 'NO',
                      groupValue: inspeccionProvider.aceptaTerminos.toString(),
                      onChanged: (value) {
                        inspeccionProvider.updateTerminos(value.toString());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _TerminosCondiciones extends StatelessWidget {
  const _TerminosCondiciones({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Text(
            '''APPEARS S.A.S propietaria del aplicativo QINSPECTING, dando cumplimiento estricto a lo establecido en la Ley 1581 de 2012 y en el Decreto 1377 de 2013. Establece la presente política para la recolección, manejo, uso, tratamiento, almacenamiento e intercambio de todas aquellas actividades que constituyan tratamiento de datos personales.
APPEARS S.A.S, identificado con Nit. 901.377.198-6, con sede principal en la calle 24 No. 1-121 Villavicencio, Departamento del Meta en Colombia, portal web www.qinspecting.com, www.appears.com.co Correo electrónico gerencia@appears.com.co, teléfono (571) 3137840166; desarrollador y propietaria del aplicativo QINSPECTING Y como responsable del tratamiento de sus datos personales, para el desarrollo de sus actividades propias, así como para el fortalecimiento de sus relaciones con terceros.''',
            textAlign: TextAlign.justify,
          ),
          Text(
            'Definiciones:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.start,
          ),
          Text(
            '''-Autorización: Consentimiento previo, expreso e informado del Titular para llevar a cabo el Tratamiento de datos personales.'),
-Aviso de privacidad: Comunicación verbal o escrita generada por el Responsable, dirigida al Titular para el Tratamiento de sus Datos Personales, mediante la cual se le informa acerca de la existencia de las Políticas de Tratamiento de información que le serán aplicables, la forma de acceder a las mismas y las finalidades del Tratamiento que se pretende dar a los datos personales.'),
-Base de datos: Conjunto organizado de datos personales que sea objeto de Tratamiento.'),
-Dato personal: Cualquier información vinculada o que pueda asociarse a una o varias personas naturales determinadas o determinables.'),
-Dato sensible: Aquel dato que afecta la intimidad del titular o cuyo uso indebido puede generar su discriminación, tales como aquellos que revelen el origen racial o étnico, la orientación política, las convicciones religiosas o filosóficas, la pertenencia a sindicatos, organizaciones sociales, de derechos humanos o que promueva intereses de cualquier partido político o que garanticen los derechos y garantías de partidos políticos de oposición así como los datos relativos a la salud, a la vida sexual y los datos biométricos, entre otros, la captura de imagen fija o en movimiento, huellas digitales, fotografías, iris, reconocimiento de voz, facial o de palma de mano, etc.'),
-Encargado del tratamiento: Persona natural o jurídica, pública o privada, que por sí misma o en asocio con otros, realice el Tratamiento de datos personales por cuenta del Responsable del Tratamiento.'),
-Responsable del tratamiento: Persona natural o jurídica, pública o privada, que por sí misma o en asocio con otros, decida sobre la base de datos y/o el Tratamiento de los datos.'),
-Titular: Persona natural cuyos datos personales sean objeto de Tratamiento.'),
-Tratamiento: Cualquier operación o conjunto de operaciones sobre datos personales, tales como la recolección, almacenamiento, uso, circulación o supresión.''',
            textAlign: TextAlign.justify,
          ),
          Text(
            'Principios:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.end,
          ),
          Text(
              '''-Principio de legalidad: La captura, recolección y tratamiento de datos personales, se realizara bajo las disposiciones vigentes y aplicables que rigen el tratamiento de datos personales y demás derechos fundamentales vinculados a estos.'),
-Principio de libertad: La captura, recolección y tratamiento de datos personales sólo puede llevarse a cabo con el consentimiento, previo, expreso e informado del Titular. Los datos personales no podrán ser obtenidos o divulgados sin previa autorización, o en ausencia de mandato legal, estatutario, o judicial que releve el consentimiento.
-Principio de finalidad: La captura, recolección y tratamiento de datos personales a los que tenga acceso y sean acopiados y recogidos por QINSPECTING, estarán subordinados y atenderán una finalidad legítima, la cual debe serle informada al respectivo titular de los datos personales.
-Principio de veracidad o calidad: La información sujeta a uso, captura, recolección y tratamiento de datos personales debe ser veraz, completa, exacta, actualizada, comprobable y comprensible. Se prohíbe el tratamiento de datos parciales, incompletos, fraccionados o que induzcan a error.
-Principio de transparencia: La captura, recolección y tratamiento de datos personales debe garantizarse el derecho del Titular a obtener de QINSPECTING, en cualquier momento y sin restricciones, información acerca de la existencia de cualquier tipo de información o dato personal que sea de su interés o titularidad.
-Principio de acceso y circulación restringida: Los datos personales, salvo la información pública, no podrán estar disponibles en Internet u otros medios de divulgación o comunicación masiva, salvo que el acceso sea técnicamente controlable para brindar un conocimiento restringido sólo a los titulares o terceros autorizados. Para estos propósitos la obligación de QINSPECTING será de medio.
-Principio de seguridad: Los datos personales e información usada, capturada, recolectada y sujeta a tratamiento por QINSPECTING será objeto de protección en la medida en que los recursos técnicos y estándares mínimos así lo permitan, a través de la adopción de medidas tecnológicas de protección, protocolos de seguridad, y todo tipo de medidas administrativas que sean necesarias para otorgar seguridad a los registros y bases de datos electrónicos evitando su adulteración, modificación, pérdida, consulta, y en general en contra de cualquier uso o acceso no autorizado.
-Principio de confidencialidad: Todas y cada una de las personas que administran, manejen, actualicen o tengan acceso a informaciones de cualquier tipo que se encuentre en Bases o Bancos de Datos, se comprometen a conservar y mantener de manera estrictamente confidencial y no revelarla a terceros, todas las informaciones personales, comerciales, contables, técnicas, comerciales o de cualquier otro tipo suministradas en la ejecución y ejercicio de sus funciones.
Todas las personas que trabajen actualmente o sean vinculadas a futuro para tal efecto, en la administración y manejo de bases de datos.''',
              textAlign: TextAlign.justify),
          Text(
            'Tratamiento de Datos:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.end,
          ),
          Text(
              'QINSPECTING, como responsable de tratamiento de datos personales para el desarrollo de sus actividades propias, así como para el fortalecimiento de sus relaciones con terceros, recolecta, procesa, almacena, usa, solicita, suministra, compila, confirma, analiza, estudia, conserva, actualizar, dar tratamiento y dispone de los datos suministrados y se incorporan a distintas bases de datos o repositorios electrónicos, correspondiente con quienes tiene o ha tenido relación, tales como: trabajadores y familiares de éstos, socios, clientes, contratistas, proveedores, deudores y partes interesadas.',
              textAlign: TextAlign.justify),
          Text(
            'Tratamiento de datos sensibles:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.end,
          ),
          Text(
              '''Se podrá hacer uso y tratamiento de los datos catalogados como sensibles cuando:
-El titular haya dado su autorización explícita a dicho tratamiento, salvo en los casos que por ley no sea requerido el otorgamiento de dicha autorización.
-El tratamiento sea necesario para salvaguardar el interés vital del titular y este se encuentre física o jurídicamente incapacitado. En estos eventos, los representantes legales deberán otorgar su autorización.
-El tratamiento sea efectuado en el curso de las actividades legítimas y con las debidas garantías por parte de una fundación, ONG, asociación o cualquier otro organismo sin ánimo de lucro, cuya finalidad sea política, filosófica, religiosa o sindical, siempre que se refieran exclusivamente a sus miembros o a las personas que mantengan contactos regulares por razón de su finalidad. En estos eventos, los datos no se podrán suministrar a terceros sin la autorización del titular.''',
              textAlign: TextAlign.justify),
          Text(
            'Finalidad para el tratamiento:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.end,
          ),
          Text(
            '''-El tratamiento se refiere a datos que sean necesarios para el reconocimiento, ejercicio o defensa de un derecho en un proceso judicial.
-El tratamiento tenga una finalidad histórica y estadística.
-Envío de información.
-Contactar eventualmente.
-Fortalecimiento de relaciones con proveedores, clientes, contratistas y partes interesadas.
-Controlar el acceso a las oficinas de QINSPECTING., y establecer medidas de seguridad, incluyendo el establecimiento de zonas video-vigiladas.
-Dar respuesta a consultas, peticiones, quejas y reclamos que sean realizadas por los titulares y organismos de control y trasmitir los datos personales a las demás autoridades que en virtud de la ley aplicable deban recibir los datos personales.
-Para la atención de requerimientos judiciales o administrativos y el cumplimiento de mandatos judiciales o legales.
-Registrar sus datos personales en los sistemas de información de QINSPECTING y en sus bases de datos operativos, administrativos, etc.
-Administración de la relación contractual, legal o comercial que existe entre QINSPECTING y el Titular.
-Soportar los procesos de auditoría de QINSPECTING
-Emisión y envío de comprobantes, reportes, constancias y certificaciones.
-Consulta en bases de datos públicas para verificación de antecedentes.
-Gestión de nómina pago de salario, prestaciones sociales, beneficios extralegales y demás conceptos económicos asociados a la relación laboral.
-Seguimiento a horarios de ingreso y salida de empleados.
-Realización de procesos disciplinarios, llamados de atención, descargos y terminación de relación laboral.
-Elaboración de contratos, órdenes de compra o servicios, informes y reportes relacionados con la relación comercial sostenida entre las partes. -Para la determinación de obligaciones pendientes, el reporte a centrales de información y la consulta de información financiera e historia crediticia.
-Realización de pagos de anticipos, facturas y cuentas de cobro.
-Adelantar convenios comerciales.
-Confirmar los datos necesarios para la entrega de productos y/o prestación de servicios.
-Realizar estudios de crédito, riesgo crediticio, adelantar las acciones de cobro y de recuperación de cartera cobranza.
-Realizar encuestas de satisfacción.
-Ejecutar campañas de publicidad y mercadeo.''',
            textAlign: TextAlign.justify,
          ),
          Text(
            'Derechos del titular:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.end,
          ),
          Text(
            '''Los derechos que asisten al titular de los datos son los siguientes:
-Conocer, actualizar y rectificar los datos personales sobre los cuales QINSPECTING, está realizando el tratamiento, esto se podrá solicitar en cualquier momento, si encuentra que sus datos son parciales, inexactos, incompletos, fraccionados, induzcan a error, o aquellos cuyo tratamiento esté expresamente prohibido o no haya sido autorizado.
-Solicitar prueba de la autorización otorgada a QINSPECTING, cuando expresamente se exceptúe como requisito para el tratamiento, de conformidad con lo previsto en el artículo 10 de la ley 1581 de 2012.
-Presentar ante la Superintendencia de Industria y Comercio quejas por infracciones a lo dispuesto en la Ley de Protección de Datos Personales.
-Solicitar a QINSPECTING, la supresión de los datos cuando en el Tratamiento no se respeten los principios, derechos y garantías constitucionales y legales. La revocatoria y/o supresión procederá cuando la Superintendencia de Industria y Comercio haya determinado que en el Tratamiento la entidad o el encargado han incurrido en conductas contrarias a esta ley y a la constitución.
-Acceder de forma gratuita a sus Datos Personales objeto de Tratamiento.
-Ser informado por QINSPECTING, previa solicitud, respecto del uso que ésta le ha dado a sus Datos Personales.
Deberes de QINSPECTING como responsable del tratamiento de datos personales.
QINSPECTING, cuando actúe como responsable del tratamiento de datos personales, cumplirán con los siguientes deberes:
-Solicitar y conservar, copia de esta política con la respectiva autorización otorgada por el titular.
-Garantizar al titular, en todo tiempo, el pleno y efectivo ejercicio del derecho de hábeas data.
-Informar debidamente al titular sobre la finalidad de la recolección y los derechos que le asisten por virtud de la autorización otorgada.
-Conservar la información bajo las condiciones de seguridad necesarias para impedir su adulteración, pérdida, consulta, uso o acceso no autorizado o fraudulento a esta.
-Garantizar que la información que se suministre al encargado del tratamiento sea veraz, completa, exacta, actualizada, comprobable y comprensible.
-Actualizar la información, comunicando de forma oportuna al encargado del tratamiento, todas las novedades respecto de los datos que previamente le haya suministrado y adoptar las demás edidas necesarias para que la información suministrada a este se mantenga actualizada.
-Rectificar la información cuando sea incorrecta y comunicar lo requerido al encargado del tratamiento.
-Suministrar al encargado del tratamiento, según el caso, únicamente datos cuyo tratamiento esté previamente autorizado.
-Exigir al encargado del tratamiento en todo momento, el respeto a las condiciones de seguridad y privacidad de la información del titular.
-Tramitar las consultas y reclamos formulados.
-Informar al encargado del tratamiento cuando determinada información se encuentra en discusión por parte del titular, una vez se haya presentado la reclamación y no haya finalizado el rámite respectivo.
-Informar a solicitud del titular sobre el uso dado a sus datos.
-Informar a la autoridad de protección de datos cuando se presenten violaciones a las políticas de protección de la información y existan riesgos en la administración de la información de los itulares.
Mecanismos dispuestos para la atención de peticiones, consultas y reclamos.
El titular de la información puede ejercer sus derechos a conocer, actualizar, rectificar, suprimir información y revocar la autorización, se deberá contactar con QINSPECTING, a través de los medios dispuestos para ello, sede principal en la calle 24 No. 1-121 Manzana 1 - 2 en la ciudad de Villavicencio – Departamento del Meta en Colombia, correo electrónico contactenos@appears.com, el requerimiento (oficio) deberá estar acompañado de una copia del documento de identidad del Titular.
Los Titulares de los Datos Personales, podrán en todo momento, solicitar a QINSPECTING, la supresión de sus datos y/o revocar la autorización, mediante la presentación de un reclamo de acuerdo con lo establecido en el artículo 15 de la Ley 1581 de 2012.
Seguridad de datos personales QINSPECTING, en estricta aplicación del principio de seguridad en el tratamiento de datos personales, proporcionará las medidas técnicas, humanas y administrativas que sean necesarias para otorgar seguridad a los registros evitando su adulteración, pérdida, consulta, uso o acceso no autorizado o fraudulento. La obligación y responsabilidad de QINSPECTING, se limita a disponer de los medios adecuados para este fin.
                      ''',
            style: TextStyle(),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
