class FiatHelper {
  String getIbanFormat(String iban) {
    String ibanFormat = '';
    int ibanLength = iban.length;
    int iterationStep = 4;
    int specialSelectedCounter = 20;

    for (int i = 0; i < ibanLength; i += iterationStep) {
      if (i != specialSelectedCounter) {
        ibanFormat += iban.substring(i, i + iterationStep) + ' ';
      } else {
        ibanFormat += iban.substring(i, i + iterationStep ~/ 2);
      }
    }
    return ibanFormat;
  }
}