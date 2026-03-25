class DetectionResult {
  final String imagePath;
  final String cropName;
  final double confidence;
  final String diseaseName;
  final String rawLabel; // Added to store exact folder name
  final String severity;
  final String description;
  final List<String> symptoms;
  final TreatmentPlan organicTreatment;
  final TreatmentPlan chemicalTreatment;
  final String? highlight;
  final String? highlightUrl;

  const DetectionResult({
    required this.imagePath,
    required this.cropName,
    required this.confidence,
    required this.diseaseName,
    required this.rawLabel,
    required this.severity,
    required this.description,
    required this.symptoms,
    required this.organicTreatment,
    required this.chemicalTreatment,
    this.highlight,
    this.highlightUrl,
  });
}

class TreatmentPlan {
  final String title;
  final List<String> steps;
  final String duration;
  final String? sourceUrl;

  const TreatmentPlan({
    required this.title,
    required this.steps,
    required this.duration,
    this.sourceUrl,
  });
}

// Mock data generator for prototyping
class MockDetectionData {
  static DetectionResult getResult(String imagePath, String crop) {
    if (crop.toLowerCase() == 'tomato') {
      return getResultByDisease(imagePath, 'Tomato', 'Early Blight');
    } else {
      return getResultByDisease(imagePath, 'Rice', 'Rice Blast');
    }
  }

  static DetectionResult getResultByDisease(String imagePath, String crop, String diseaseName, {double? confidence}) {
    // Normalize disease name: replace underscores with spaces and lowercase
    final normalizedName = diseaseName.replaceAll('_', ' ').toLowerCase();
    final rawLabel = diseaseName; // Store original label (e.g. Early_blight)

    // Default/Fallback
    DetectionResult result = DetectionResult(
      imagePath: imagePath,
      cropName: crop,
      confidence: confidence ?? 0.0,
      diseaseName: diseaseName.replaceAll('_', ' '), // Show clean name
      rawLabel: rawLabel,
      severity: 'Unknown',
      description: 'Could not identify the specific details for this disease.',
      symptoms: [],
      organicTreatment: const TreatmentPlan(title: 'Consult Expert', steps: [], duration: ''),
      chemicalTreatment: const TreatmentPlan(title: 'Consult Expert', steps: [], duration: ''),
    );

    if (crop.toLowerCase() == 'tomato') {
       if (normalizedName.contains('early blight')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Tomato',
            confidence: confidence ?? 0.96,
            diseaseName: 'Early Blight',
            rawLabel: 'Early_blight',
            severity: 'High',
            description: 'Fungal infection caused by Alternaria solani. It causes concentric rings on leaves and can severely impact yield if untreated.',
            symptoms: [
              'Concentric rings on lower leaves (Target-board effect)',
              'Yellowing of tissue surrounding spots',
              'Stem lesions near ground level',
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Thoroughly turn under tomato crop debris.',
                'Use land that has been out of tomato, potato, or eggplant for at least 2-3 years.',
                'Provide for adequate, season-long nitrogen supply.',
                'Use high quality, disease-free seed.',
                'Control weeds to provide good air circulation.'
              ],
              duration: 'Seasonal',
              sourceUrl: 'https://ipm.cahnr.uconn.edu/early-blight-management-in-fresh-market-tomatoes/',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Mix fat-free milk with water in a 1:1 ratio and apply it using a spray bottle.',
                'Apply seaweed spray to change leaf pH.',
                'For all infected plants, destroy and drop leaves by bagging and disposing in rubbish.',
                'Do not compost infected material.'
              ],
              duration: 'Immediate',
              sourceUrl: 'https://www.sgaonline.org.au/early-blight-of-tomatoes/',
            ),
            highlight: 'Use of preventative applications of a copper or chlorothalonil-containing fungicide labeled for use on vegetables may be warranted.',
            highlightUrl: 'https://hort.extension.wisc.edu/articles/early-blight/',
          );
       } else if (normalizedName.contains('bacterial spot')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Tomato',
            confidence: confidence ?? 0.94,
            diseaseName: 'Bacterial Spot',
            rawLabel: 'Bacterial_spot',
            severity: 'Moderate',
            description: 'Caused by Xanthomonas bacteria. Appears as small, water-soaked spots that turn dark and necrotic, often with a yellow halo.',
            symptoms: [
              'Small, water-soaked spots on leaves',
              'Spots turn dark brown/black',
              'Yellow halo around spots'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Use pathogen-free seed and disease-free transplants.',
                'Avoid sprinkler irrigation and cull piles near greenhouse or field operations.',
                'Rotating with a nonhost crop also helps control the disease.',
                'Pruning lower leaves and tying plants to improve airflow.'
              ],
              duration: 'Preventative',
              sourceUrl: 'https://ipm.ucanr.edu/agriculture/tomato/bacterial-spot/#MANAGEMENT',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Plants should be destroyed: a plant with bacterial spot cannot be cured.',
                'Removing symptomatic plants from your garden to prevent spreading.',
                'Bury or hot compost the affected plants.',
                'DO NOT eat symptomatic fruit.'
              ],
              duration: 'Immediate',
              sourceUrl: 'https://hort.extension.wisc.edu/articles/bacterial-spot-of-tomato/',
            ),
            highlight: 'Use pesticides: copper hydroxide and copper hydroxide + mancozeb.',
            highlightUrl: 'https://ipm.ucanr.edu/agriculture/tomato/bacterial-spot/#MANAGEMENT',
          );
       } else if (normalizedName.contains('late blight')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Tomato',
            confidence: confidence ?? 0.97,
            diseaseName: 'Late Blight',
            rawLabel: 'Late_blight',
            severity: 'Critical',
            description: 'A destructive disease caused by Phytophthora infestans. It spreads rapidly in cool, wet weather and can kill plants quickly.',
            symptoms: [
              'Large, dark brown blotches on leaves',
              'White fungal growth on undersides in wet weather',
              'Brown, firm rot on tomato fruits'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Remove any nearby volunteer tomato and potato plants.',
                'Check transplants to ensure they are free of late blight before planting.',
                'Avoid sprinkler irrigation.',
                'Disc tomato fields in fall to eliminate winter reservoir.'
              ],
              duration: 'Preventative',
              sourceUrl: 'https://ipm.ucanr.edu/agriculture/tomato/late-blight/#gsc.tab=0',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Weekly spraying applications of fungicide to prevent further infection.',
                'Avoid harvesting tomato fruits with visible disease lesions.',
                'Rogue and either bury or burn severely infected plants.',
                'Rotate tomatoes with unrelated vegetables for 2-3 years.'
              ],
              duration: 'Immediate',
              sourceUrl: 'https://www.gardentech.com/blog/pest-id-and-prevention/fight-blight-on-your-tomatoes',
            ),
            highlight: 'Apply fungicides: Mandipropamid, chlorothalonil, fluazinam, and mancozeb.',
            highlightUrl: 'https://plantix.net/en/library/plant-diseases/100046/tomato-late-blight/',
          );
       } else if (normalizedName.contains('septoria')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Tomato',
            confidence: confidence ?? 0.95,
            diseaseName: 'Septoria Leaf Spot',
            rawLabel: 'Septoria_leaf_spot',
            severity: 'Moderate',
            description: 'Fungal disease causing numerous small, circular spots with gray centers and dark borders. Usually starts on lower leaves and spread upwards.',
            symptoms: [
              'Circular spots with gray/white centers',
              'Dark brown margins around spots',
              'Lower leaves yellow and drop'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Destroy infested plants or rotate crops to avoid infected debris.',
                'Use Septoria Leaf Spot-resistant tomato varieties.',
                'Increase spacing between plants to improve airflow and decrease humidity.',
                'Apply ~1 inch of high-quality mulch; avoid over-mulching to prevent wet soils.',
                'Staking or caging plants to raise them off the ground.',
                'Use soaker hoses at the base instead of overhead watering.',
                'Strict weed control.'
              ],
              duration: 'Seasonal',
              sourceUrl: 'https://hort.extension.wisc.edu/articles/septoria-leaf-spot/',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Thinning of whole plants or removal of selected branches to increase airflow.',
                'Apply fungicides containing Copper (Hydroxide, Sulfate, Oxychloride Sulfate), Chlorothalonil, or Mancozeb at the very early course of the disease.'
              ],
              duration: 'Early detection',
              sourceUrl: 'https://www.missouribotanicalgarden.org/gardens-gardening/your-garden/help-for-the-home-gardener/advice-tips-resources/insects-pests-and-problems/diseases/fungal-spots/septoria-leaf-spot-of-tomato',
            ),
            highlight: 'To protect new leaves, use fungicides labeled for vegetables containing copper or chlorothalonil.',
            highlightUrl: 'https://hort.extension.wisc.edu/articles/septoria-leaf-spot/',
          );
       } else if (normalizedName.contains('yellow leaf curl') || normalizedName.contains('virus')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Tomato',
            confidence: confidence ?? 0.98,
            diseaseName: 'Yellow Leaf Curl Virus',
            rawLabel: 'Yellow_Leaf_Curl_Virus',
            severity: 'High',
            description: 'A viral disease transmitted by whiteflies. It causes severe stunting and yield reduction. Infected plants often bear no fruit.',
            symptoms: [
              'Upward curling or cupping of leaves',
              'Yellowing (chlorosis) of leaf margins',
              'Stunted plant growth',
              'Flower drop'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Select TYLCV-resistant varieties.',
                'Use virus- and whitefly-free transplants.',
                'Use fine-mesh floating row covers.',
                'Maintain good weed management in and around fields.'
              ],
              duration: 'Continuous',
              sourceUrl: 'https://ipm.ucanr.edu/agriculture/tomato/tomato-yellow-leaf-curl/',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Plants should be rogued and destroyed to prevent disease spread.',
                'Carefully cover symptomatic plants with a plastic bag before removal.',
                'Spray the undersides of leaves thoroughly with insecticidal soap or neem oil.',
                'Rotate at least two insecticides between applications.'
              ],
              duration: 'Active control',
              sourceUrl: 'https://ipm.ifas.ufl.edu/agricultural_ipm/tylcv_home_mgmt.shtml',
            ),
            highlight: 'Use Insecticide: Flupyradifurone, Cyazypyr, Sulfoxaflor, Zeta-cypermethrin, Pymetrozine.',
            highlightUrl: 'https://pmc.ncbi.nlm.nih.gov/articles/PMC4684678/',
          );
       } else if (normalizedName.contains('healthy')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Tomato',
            confidence: confidence ?? 0.98,
            diseaseName: 'Healthy',
            rawLabel: 'Healthy',
            severity: 'None',
            description: 'Your plant looks healthy! Keep up the good work.',
            symptoms: [],
            organicTreatment: const TreatmentPlan(
              title: 'Maintenance',
              steps: ['Regular watering', 'Monitor for pests'],
              duration: 'Ongoing',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'None',
              steps: [],
              duration: '',
            ),
          );
       }
       // Add more cases as needed based on labels
    } else if (crop.toLowerCase() == 'rice') {
        if (normalizedName.contains('blast')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.92,
            diseaseName: 'Leaf Blast',
            rawLabel: 'Rice_Blast',
            severity: 'Moderate',
            description: 'Caused by the fungus Magnaporthe oryzae. It can affect all parts of the plant, but leaf blast is most common.',
            symptoms: [
              'Diamond or spindle-shaped lesions',
              'Gray or white centers with reddish-brown borders',
              'Lesions can coalesce to kill entire leaves'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Plant resistant varieties.',
                'Adjust planting time; sow seeds early, when possible, after the onset of the rainy season.',
                'Split nitrogen fertilizer application into two or more treatments.',
                'Flood the field as often as possible.',
                'Use certified disease-free seeds from reliable sources.',
                'Implement crop rotation with non-host crops.',
                'Ensure good drainage and avoid over-irrigation.'
              ],
              duration: 'Ongoing season',
              sourceUrl: 'https://keyserver.lucidcentral.org/key-server/data/0e090d01-0209-460e-810c-0d060708030c/media/Html/Blast_%28Leaf_and_Collar%29.htm',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Use biocontrol agents such as Trichoderma or bacteria like Bacillus spp. to suppress the growth of Magnaporthe oryzae.',
                'These agents can be incorporated into the soil or applied as foliar sprays.'
              ],
              duration: 'As needed',
              sourceUrl: 'https://agri.bot/docs/leaf-blast-information-in-paddy-crop/',
            ),
            highlight: 'When leaf blast incidence is high or resistant varieties are not available, apply fungicides in a timely manner. Consult local agricultural authorities or specialists for recommended fungicides and application timings.',
            highlightUrl: 'https://agri.bot/docs/leaf-blast-information-in-paddy-crop/',
          );
        } else if (normalizedName.contains('brown spot')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.88,
            diseaseName: 'Brown Spot',
            rawLabel: 'Brown_Spot',
            severity: 'Moderate',
            description: 'A fungal disease that often indicates nutritional deficiency, especially potassium or silica.',
            symptoms: [
              'Small, circular to oval brown spots',
              'Spots have yellow halos',
              'Symptoms usually appear on older leaves first'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Monitor soil nutrients regularly.',
                'Apply required fertilizers.',
                'Apply calcium silicate slag before planting for soils that are low in silicon.',
                'Plant rice varieties genetically resistant to brown spots.',
                'Treat seeds with hot water (53−54°C) for 10−12 minutes before planting.',
                'Use slow-releasing nitrogen fertilizers.'
              ],
              duration: 'Ongoing',
              sourceUrl: 'http://www.knowledgebank.irri.org/training/fact-sheets/pest-management/diseases/item/brown-spot',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Tilt Fungicide (Propiconazole 25% EC)',
                'Contaf Plus Fungicide (Hexaconazole 5% SC)',
                'Merger Fungicide (Tricyclazole 18% + Mancozeb 62% WP)',
                'Godiwa Super Fungicide (Azoxystrobin 18.2% + Difenoconazole 11.4% SC)',
              ],
              duration: 'As needed',
              sourceUrl: 'https://www.bighaat.com/kisan-vedika/blogs/management-of-brown-spot-in-rice-paddy?srsltid=AfmBOopXfqaepE07UbQqVHJtkOMahjeAhDS6lacCsvu0MAkOrQJXwCgZ',
            ),
            highlight: 'Use fungicides as seed treatment: Iprodione, propiconazole, azoxystrobin, trifloxystrobin, and carbendazim.',
            highlightUrl: 'https://www.bighaat.com/kisan-vedika/blogs/management-of-brown-spot-in-rice-paddy?srsltid=AfmBOopXfqaepE07UbQqVHJtkOMahjeAhDS6lacCsvu0MAkOrQJXwCgZ',
          );
        } else if (normalizedName.contains('bacterial leaf blight')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.90,
            diseaseName: 'Bacterial Leaf Blight',
            rawLabel: 'Bacterial_Leaf_Blight',
            severity: 'High',
            description: 'A serious bacterial disease caused by Xanthomonas oryzae. It causes wilting and yellowing of leaves, potentially devastating yields.',
            symptoms: [
              'Water-soaked streaks on leaf blades',
              'Yellow to white lesions with wavy margins',
              'Milky bacterial ooze droplets in morning'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Plant Xanthomonas-indexed seed or treat seed in a hot water dip.',
                'Use of furrow irrigation rather than sprinkles may aid in reducing disease pressure.',
                'Turn under carrot residue to hasten decomposition.',
                'Avoid continuous carrot culture and practice.',
                'Apply a 2 to 3 year crop rotation scheme.',
                'Use pesticides: Copper sulfate, Copper hydroxide, Copper octanoate.'
              ],
              duration: 'Preventative',
              sourceUrl: 'https://ipm.ucanr.edu/agriculture/carrot/bacterial-leaf-blight/#gsc.tab=0',
            ),
                        chemicalTreatment: const TreatmentPlan(
                          title: 'Control Measures',
                          steps: [
                            'Prune infected twigs 10–12 inches below the visible symptoms.',
                            'Destroy removed branches by burning to prevent disease spread.',
                            'Disinfect pruning tools after each cut by soaking for at least 30 seconds in a 10% bleach solution, or using 70% alcohol.',
                            'If bleach is used, rinse and oil tools after pruning to prevent rusting.'
                          ],
                          duration: 'Immediate',
                          sourceUrl: 'https://hort.extension.wisc.edu/articles/bacterial-blight/',
                        ),
                        highlight: 'Use pesticides: Copper sulfate, Copper hydroxide, Copper octanoate.',
                        highlightUrl: 'https://ipm.ucanr.edu/agriculture/carrot/bacterial-leaf-blight/#gsc.tab=0',
                      );
                   } else if (normalizedName.contains('sheath blight')) {          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.89,
            diseaseName: 'Sheath Blight',
            rawLabel: 'Sheath_Blight',
            severity: 'High',
            description: 'A fungal disease affecting leaf sheaths, caused by Rhizoctonia solani. It thrives in warm, humid conditions and dense canopies.',
            symptoms: [
              'Oval/elliptical greenish-gray spots',
              'Irregular dark brown borders on spots',
              'Lesions spread upward from waterline'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Apply urea in recommended dosages or based on leaf color chart.',
                'Maintain weed control and avoid excessive nitrogen.',
                'Avoid conditions favoring disease: high temperature, high humidity, foggy/dark periods, shade.',
                'Use varieties with clean plant base (fewer unproductive tillers); avoid short, dense plants with high nitrogen.',
                'Detect inoculum early and monitor canopy microclimate.',
                'Clear debris after harvest and dry fields to reduce sclerotia survival.',
                'Prepare slightly acidic soil (around pH 5.0) and enrich with boron for bacterial treatments.',
                'Promote beneficial microbes via crop rotation, soil solarization, summer deep plowing, and high farmyard manure.'
              ],
              duration: 'Seasonal',
              sourceUrl: 'https://doa.gov.lk/rrdi_ricediseases_sheathblight/',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'If disease spreads quickly, apply fungicides: Hexconazole 50 g/L EC (32 ml/16 L), Propiconazole 250 g/L EC (16 ml/16 L), Thiophanate methyl 70% WP (16 g/16 L), Pencicuron 25% WP (32 g/16 L), or Tebuconazole 250 g/L EC (10 ml/16 L).',
                'Consider biocontrol agents: Bacillus subtilis, Pseudomonas fluorescens, marine associated pseudomonads, Streptomyces, and Trichoderma.',
                'For the next season: use certified disease-free seed, deep plough to bury residues, use recommended seed rate (2 bushels/acre) for direct sowing, maintain average plant population, add burnt paddy husk (250 kg/acre), and avoid infected straw.'
              ],
              duration: 'As needed',
              sourceUrl: 'https://www.tezu.ernet.in/krishi/Management-of-SB.php',
            ),
            highlight: 'If the disease spread fast, following fungicides could be applied: Hexconazole 50G/L EC, Propiconazole 250 G/L EC, Thiophanate methyl 70% WP, Pencicuron 25% WP, Tebuconazole 250g/l EC.',
            highlightUrl: 'https://doa.gov.lk/rrdi_ricediseases_sheathblight/',
          );
        } else if (normalizedName.contains('tungro')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.93,
            diseaseName: 'Tungro Virus',
            rawLabel: 'Tungro',
            severity: 'Severe',
            description: 'A viral disease transmitted by green leafhoppers. It causes severe stunting and discoloration, often leading to total crop loss if widespread.',
            symptoms: [
              'Yellow or orange-yellow leaf discoloration',
              'Stunted plant growth',
              'Reduced number of tillers',
              'Delayed flowering'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Preventive Measures',
              steps: [
                'Grow tungro- or leafhopper-resistant varieties.',
                'Practice synchronous planting with surrounding farms.',
                'Adjust planting times to when green leafhoppers are not in season/abundant.',
                'Plow infected stubble immediately after harvest to reduce inoculation sources.'
              ],
              duration: 'Prevention',
              sourceUrl: 'http://www.knowledgebank.irri.org/training/fact-sheets/pest-management/diseases/item/tungro',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Control Measures',
              steps: [
                'Uproot the infected plants at the primary level of infection when a very few plants are infected.',
                'Use a light trap and set up a bowl of soapy water under the light trap to trap the green leaf hoppers.',
                'Apply insecticides during early morning and/or late afternoon.',
                'Spray pesticides (Malathion, Carbaryl, Isoprocarb). Note: use a mask when doing this.'
              ],
              duration: 'Immediate',
              sourceUrl: 'https://plantwiseplusknowledgebank.org/doi/full/10.1079/pwkb.20167800402',
            ),
            highlight: 'Spray pesticides (Note: use a mask): Malathion, Carbaryl, Isoprocarb.',
            highlightUrl: 'https://plantwiseplusknowledgebank.org/doi/full/10.1079/pwkb.20167800402',
          );
        } else if (normalizedName.contains('smut')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.85,
            diseaseName: 'Leaf Smut',
            rawLabel: 'Leaf_Smut',
            severity: 'Low',
            description: 'A minor fungal disease caused by Entyloma oryzae. Usually doesn\'t cause significant yield loss.',
            symptoms: [
              'Small, black, slightly raised spots',
              'Spots are angular in shape',
              'Usually appears late in the season'
            ],
            organicTreatment: const TreatmentPlan(
              title: 'Standard Care',
              steps: [
                'Maintain proper spacing',
                'Avoid excessive nitrogen',
                'Remove infected crop residue after harvest'
              ],
              duration: 'Seasonal',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'Prevention',
              steps: [
                'Usually not required for minor infections',
                'Standard fungicides can control it'
              ],
              duration: 'N/A',
            ),
          );
        } else if (normalizedName.contains('healthy')) {
          result = DetectionResult(
            imagePath: imagePath,
            cropName: 'Rice',
            confidence: confidence ?? 0.99,
            diseaseName: 'Healthy',
            rawLabel: 'Healthy',
            severity: 'None',
            description: 'Your rice crop looks healthy and vibrant!',
            symptoms: [],
            organicTreatment: const TreatmentPlan(
              title: 'Maintenance',
              steps: ['Maintain water levels', 'Monitor for pests'],
              duration: 'Ongoing',
            ),
            chemicalTreatment: const TreatmentPlan(
              title: 'None',
              steps: [],
              duration: '',
            ),
          );
        }
    }
    
    // If we have a result but confidence is 0 (fallback), just return it with the passed disease name
    if (result.confidence == 0.0 && diseaseName != 'Unknown') {
        return DetectionResult(
            imagePath: imagePath,
            cropName: crop,
            confidence: confidence ?? 0.85, // Dummy confidence for unknown specific data but known label
            diseaseName: diseaseName.replaceAll('_', ' '),
            rawLabel: rawLabel,
            severity: 'Unknown',
            description: 'Detected $diseaseName. Detailed info not yet available.',
            symptoms: [],
            organicTreatment: const TreatmentPlan(title: 'Consult Expert', steps: [], duration: ''),
            chemicalTreatment: const TreatmentPlan(title: 'Consult Expert', steps: [], duration: ''),
        );
    }
    
    return result;
  }
}
