import { Configuration, OpenAIApi } from "openai";
import env from "../env";

export class OpenAIClient {
  config: Configuration;
  openaiAPI: OpenAIApi;

  constructor() {
    this.config = new Configuration({
      apiKey: env.OPENAI_API_KEY,
    });
    this.openaiAPI = new OpenAIApi(this.config);
  }

  async createCompletion (sample:string, question:string):Promise<string>{
    const prompt = `${sample}\nQ : ${question}\nA : `
    console.log({oa: this.openaiAPI})
    const response = await this.openaiAPI.createCompletion({
        model: "text-davinci-002",
        prompt,
        temperature: 0.17,
        max_tokens: 1024,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0,
      });  
    return response.data.choices[0].text || '';
  }
}

export const ddlModelSample = "I am a very smart model database generating bot. If you ask me to build a model for the app you describe, I'll give an answer based on that description. If the description of your application is still not clear, I will respond with \"please provide a more detailed description of your application!\"\n\nQ : create a model for a book selling application where the user is the author of the book\nA :\nmodel user {\n  external_id str [pk]\n  password str [nullable : false]\n  age int [default: 20 nullable : true]\n  profile_pict file [default: {filename: \"avatar\" size: 124.3 mime: \".jpg\"}]\n}\n\nmodel books {\n  id int [pk]\n  title str\n  author user ManyToOne OnDelete:RESTRICT\n}\n\nQ : create a model for a restaurant management app\nA :\nmodel customer {\n  external_id str [pk]\n  name str [nullable : false]\n}\n\nmodel foods{\n  name str [unique:true]\n  stock int [default:0]\n}\n\nmodel order {\n  id int [pk]\n  customer customer ManyToOne OnDelete:SETNULL\n  food customer ManyToOne OnDelete:SETNULL\n  quantity int [nullable:false]\n}\n"
