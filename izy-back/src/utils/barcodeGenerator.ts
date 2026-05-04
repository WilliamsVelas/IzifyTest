import Unit from "../models/Unit";

export const generateUniqueBarcodes = async (productName: string, qty: number): Promise<string[]> => {
  const prefix = productName.replace(/\s/g, '').substring(0, 4).toLowerCase();
  const generatedCodes = new Set<string>();

  while (generatedCodes.size < qty) {
    const randomNumbers = Math.floor(10000 + Math.random() * 90000);
    const potentialCode = `${prefix}${randomNumbers}`;

    if (!generatedCodes.has(potentialCode)) {
      const existsInDB = await Unit.exists({ barcode: potentialCode });
      if (!existsInDB) {
        generatedCodes.add(potentialCode);
      }
    }
  }

  return Array.from(generatedCodes);
};