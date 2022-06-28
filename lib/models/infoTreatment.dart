class InfoTreatment {
  final String nom;
  final String comment;
  final List<String> type;
  final String number;
  final String pays;

  final String langue;
  final List<String> filieres;
  InfoTreatment(
      {required this.nom,
      required this.type,
      required this.pays,
      required this.number,
      required this.langue,
      required this.filieres,
      required this.comment});
  Map<String, dynamic> toJson() => {
        'nom': nom,
        'type': type,
        'pays': pays,
        'number': number,
        'langue': langue,
        'filieres': filieres,
        'comment': comment
      };
  @override
  String toString() {
    return "nom:$nom,type:$type,pays:$pays,numero:$number,langue:$langue,Filieres:$filieres,autres:$comment";
  }
}
