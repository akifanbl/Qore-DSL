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

  async createCompletion (promptSample:string, question:string):Promise<string>{
    const prompt = `${promptSample}\nQ : ${question}\nA : `
    const response = await this.openaiAPI.createCompletion({
        model: "text-davinci-002",
        prompt,
        temperature: 0.17,
        max_tokens: 1024,
        top_p: 1,
        frequency_penalty: 0,
        presence_penalty: 0,
      });  
    console.log({response})
    return response.data.choices[0].text || '';
  }
}

export const ddlModelSample = "\
I am a very smart model database generating bot. If you ask me to build a model for the app you describe, I'll give an answer based on that description. If the description of your application is still not clear, I will respond with \"please provide a more detailed description of your application!\"\
Q : create a model for a book selling application where the user is the author of the book and the customer\
A :\
model books {\
  title str\
  author users ManyToOne OnDelete:RESTRICT\
}\
role author{\
}\
role customer{\
}\
Q : create a model for a restaurant management app where that save all menu, transactions, and employee data. There is 2 kind of user, employee and manager\
A :\
model menu{\
  name str [unique:true]\
  stock int [default:0]\
  price int [nullable:false]\
}\
model transaction {\
  timestamp datetime\
  food menu ManyToOne OnDelete:SET NULL\
  quantity int [nullable:false default:0]\
}\
model employee{\
  user users OneToMany OnDelete:CASCADE OnUpdate:CASCADE nullable:true\
  full_name str\
  age int\
  gender str\
  salary int\
}\
role employee{\
  select [employee menu]\
  insert update delete [menu]\
}\
role manager {\
  select insert update delete [employee menu transaction]\
}"
