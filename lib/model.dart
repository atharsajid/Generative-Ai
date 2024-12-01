class ImageEditModel {
    ImageEditModel({
        required this.created,
        required this.data,
    });

    final int? created;
    final List<Datum> data;

    factory ImageEditModel.fromJson(Map<String, dynamic> json){ 
        return ImageEditModel(
            created: json["created"],
            data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        );
    }

}

class Datum {
    Datum({
        required this.url,
    });

    final String? url;

    factory Datum.fromJson(Map<String, dynamic> json){ 
        return Datum(
            url: json["url"],
        );
    }

}


class ImageModel {
    ImageModel({
        required this.url,
        required this.seed,
        required this.cost,
    });

    final String? url;
    final int? seed;
    final double? cost;

    factory ImageModel.fromJson(Map<String, dynamic> json){ 
        return ImageModel(
            url: json["url"],
            seed: json["seed"],
            cost: json["cost"],
        );
    }

}
